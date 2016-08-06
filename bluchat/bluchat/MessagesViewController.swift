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
    
    // Define GUI for incoming and outgoing messages
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var messages: [JSQMessage]!
    var chatLog: ChatLog! {
        didSet {
            navigationItem.title = chatLog.recipientName
            messages = chatLog.messages
        }
    }
        
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load old messages and setup public info
        self.setup()
        if (messages.count > 0) {
            reloadMessagesView()
        }
        // Notify if msg received and initially hide tab bar
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.handleMPCReceivedDataWithNotification), name: "receivedMPCDataNotification", object: nil)
        self.tabBarController?.tabBar.hidden = true
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
    
    func setup() {
        // Set public info for phone -> may have to change when Facebook Button implemented
        senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
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
}

//MARK - Toolbar
extension MessagesViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        // Create msg and add to messages array
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        self.messages.append(message)
        self.finishSendingMessage()
        
        // We actually send the message here
        // Also note that we must change this if the peer is NOT connected -> have to connect through internet, then
        appDelegate.mpcManager.sendData(messageToSend: message, toPeer: appDelegate.mpcManager.session.connectedPeers[0] as MCPeerID)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        // Ignore for now
    }
}
