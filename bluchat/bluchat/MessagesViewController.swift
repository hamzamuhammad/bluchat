//
//  MessagesViewController.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/3/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import syncano_ios
import MultipeerConnectivity

class MessagesViewController: JSQMessagesViewController {
    
    // Set up backend object connections
    let channel = SCChannel(name: syncanoChannelName)
    
    // Define GUI for incoming and outgoing messages
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    
    var messages: [JSQMessage]!
    var chatLog: ChatLog! {
        didSet {
            navigationItem.title = chatLog.recipientName
            messages = chatLog.messages
        }
    }
    var cameFromDiscover: Bool?
        
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(loginViewControllerIdentifier) as! LoginViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup public info
        self.setup()
        
        // If bluetooth, set up an observer for received msg
        if (cameFromDiscover == true) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.handleMPCReceivedDataWithNotification), name: "receivedMPCDataNotification", object: nil)
        }
        else {
            self.downloadNewestMessagesFromSyncano()
        }
        
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Check if user logged in or not
        self.showLoginViewControllerIfNotLoggedIn()
    }
    
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Unpackage data stream and add to messages array
        let receivedMessage = notification.object as! JSQMessage
        messages.append(receivedMessage)
        reloadMessagesView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of resources that can be created
    }
    
    func reloadMessagesView() {
        dispatch_async(dispatch_get_main_queue()){
            self.collectionView?.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Have to implement the web based method here
        
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Have to implement the web based method here
        
        reloadMessagesView()
    }
    
    func reloadAllMessages() {
        self.messages = []
        self.reloadMessagesView()
        self.downloadNewestMessagesFromSyncano()
    }
}

//MARK - Setup
extension MessagesViewController {
    func setup() {
        // Set public info for phone -> may have to change when Facebook Button implemented
        if (cameFromDiscover == true) {
            senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
            senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
        }
        else {
            self.setupSenderData()
            self.channel.delegate = self
            self.channel.subscribeToChannel()
            self.loginViewController.delegate = self
        }
    }
    
    func setupSenderData() {
        let sender = (SCUser.currentUser() != nil) ? SCUser.currentUser()!.username : ""
        self.senderId = sender
        self.senderDisplayName = sender
    }
}

//MARK - Data Source
extension MessagesViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        // For each msg, display differently if outgoing or incoming
        let data = messages[indexPath.row]
        
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let data = self.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
        if (self.senderDisplayName == data.senderDisplayName()) {
            return nil
        }
        return NSAttributedString(string: data.senderDisplayName())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let data = self.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
        if (self.senderDisplayName == data.senderDisplayName()) {
            return 0.0
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}

//MARK - Toolbar
extension MessagesViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        // Create msg and add to messages array
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        self.messages.append(message)
 
        // We actually send the message here
        // Have to check if user is coming from DiscoverViewController or ChatsViewController
        if (cameFromDiscover == true) {
            appDelegate.mpcManager.sendData(messageToSend: message, toPeer: appDelegate.mpcManager.session.connectedPeers[0] as MCPeerID)
        }
        else {
            self.sendMessageToSyncano(message)
        }
        
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        // Ignore for now
    }
}

//MARK - Syncano
extension MessagesViewController {
    
    func sendMessageToSyncano(message: JSQMessage) {
        
        let messageToSend = Message()
        
        messageToSend.text = message.text
        messageToSend.senderId = self.senderId
        messageToSend.channel = syncanoChannelName
        messageToSend.other_permissions = .Full
        
        messageToSend.saveWithCompletionBlock { error in
            if (error != nil) {
                // ERror handling
            }
        }
        
    }
    
    func downloadNewestMessagesFromSyncano() {
        Message.please().giveMeDataObjectsWithCompletion { objects, error in
            
            if let messages = objects as? [Message] {
                
                self.messages = self.jsqMessagesFromSyncanoMessages(messages)
                self.finishReceivingMessage()
            }
            
        }
    }
    
    func jsqMessageFromSyncanoMessage(message: Message) -> JSQMessage {
        
        let jsqMessage = JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date: message.created_at, text: message.text)
        
        return jsqMessage
    }
    
    func jsqMessagesFromSyncanoMessages(messages: [Message]) -> [JSQMessage] {
        var jsqMessages: [JSQMessage] = []
        
        for message in messages {
            jsqMessages.append(self.jsqMessageFromSyncanoMessage(message))
        }
        
        return jsqMessages
    }
}

//MARK - Channels
extension MessagesViewController: SCChannelDelegate {
    
    func addMessageFromNotification(notification: SCChannelNotificationMessage) {
        let message = Message(fromDictionary: notification.payload!)
        if message!.senderId == self.senderId {
            //dont need own msg
            return
        }
        self.messages.append(self.jsqMessageFromSyncanoMessage(message!))
        self.finishReceivingMessage()
    }
    
    func updateMessageFromNotifcation(notification: SCChannelNotificationMessage) {
        
    }
    
    func deleteMessageFromNotfication(notification: SCChannelNotificationMessage) {
        
    }
    
    func channelDidReceiveNotificationMessage(notificationMessage: SCChannelNotificationMessage) {
        switch(notificationMessage.action) {
        case .Create:
            self.addMessageFromNotification(notificationMessage)
        case .Delete:
            self.deleteMessageFromNotfication(notificationMessage)
        case .Update:
            self.updateMessageFromNotifcation(notificationMessage)
        default:
            break
        }
    }
}

//MARK - Login Logic
extension MessagesViewController : LoginDelegate {
    func didSignUp() {
        self.prepareAppForNewUser()
        self.hideLoginViewController()
        
    }
    
    func didLogin() {
        self.prepareAppForNewUser()
        self.hideLoginViewController()
    }
    
    func prepareAppForNewUser() {
        self.setupSenderData()
        self.reloadAllMessages()
    }
    
    func isLoggedIn() -> Bool {
        let isLoggedIn = (SCUser.currentUser() != nil)
        return isLoggedIn
    }
    
    func logout() {
        SCUser.currentUser()?.logout()
    }
    
    func showLoginViewController() {
        self.presentViewController(self.loginViewController, animated: true) {
            
        }
    }
    
    func hideLoginViewController() {
        self.dismissViewControllerAnimated(true) {
            
        }
    }
    
    func showLoginViewControllerIfNotLoggedIn() {
        if (self.isLoggedIn() == false) {
            self.showLoginViewController()
        }
    }
    
    @IBAction func logoutPressed(sender: UIBarButtonItem) {
        self.logout()
        self.showLoginViewControllerIfNotLoggedIn()
    }
}















