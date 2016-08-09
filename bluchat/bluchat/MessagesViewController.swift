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
import CoreData

class MessagesViewController: JSQMessagesViewController {
    
    // Set up backend object connections
    let channel = SCChannel(name: syncanoChannelName)
    
    // Get global appdelegate object
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Define GUI for incoming and outgoing messages
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    
    // What JSQMessagesViewController needs to display messages
    var messages: [JSQMessage]!
    
    // What core data needs to successfully archive
    var chatMessages: [ChatMessage]!
    
    // Details regarding an existing chatlog
    var chatLog: ChatLog! {
        didSet {
            navigationItem.title = chatLog.recipientName
        }
    }

    // Check whether chat originated from discover tab
    var cameFromDiscover: Bool?
    
    // User object
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup public info
        self.setup()
        
        // Retrieve old messages from core data
        if (cameFromDiscover == false) {
            print("we attempt to load chat messages from core data")
            loadChatMessages()
            convertChatMessageToJSQMessage()
        }
        
        // If bluetooth, set up an observer for received msg
        if (cameFromDiscover == true) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.handleMPCReceivedDataWithNotification), name: "receivedMPCDataNotification", object: nil)
        }
        else {
            // Otherwise, get messages from syncano backend
            print("we download messages form syncano(shouldn't this be from core data?")
            self.downloadNewestMessagesFromSyncano()
        }
        
        // Fix the JSQmessage alignment
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        // Make the keyboard input visible
        self.tabBarController?.tabBar.hidden = true
    }
    
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Unpackage data stream and add to messages array, reload view
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
        
        // If not an MPC connection, save messages to core data
        if (cameFromDiscover == false) {
            print("we try to save message changes")
            saveChatMessageChanges()
        }
        
        // Unhide the tab bar below
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load saved messages from core data, and package them for JSQMessagesViewController
        if (cameFromDiscover == false) {
            print("we try to load messages")
            loadChatMessages()
            convertChatMessageToJSQMessage()
        }
        
        reloadMessagesView()
    }
    
    func convertChatMessageToJSQMessage() {
        
        var tempMessages: [JSQMessage]!
        
        // Check whether we have any stored messages first
        if let tempChatMessages = chatMessages {
            
            for chatMsg in tempChatMessages {
                let message = JSQMessage(senderId: chatMsg.senderID, senderDisplayName: chatMsg.senderDisplayName, date: chatMsg.date, text: chatMsg.text)
                tempMessages.append(message)
            }
            
            messages = tempMessages
        }
        else {
            // Otherwise, we initialize a blank messages array
            messages = [JSQMessage]()
        }
    }
    
    // Oddly enough, this method isn't used -- check up on this
    func reloadAllMessages() {
        self.messages = []
        self.reloadMessagesView()
        self.downloadNewestMessagesFromSyncano()
    }
    
    func setup() {
        // Set public info for phone -> may have to change when Facebook Button implemented
        if (cameFromDiscover == true) {
            senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
            senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
            let peerID = appDelegate.mpcManager.session.connectedPeers[0]
            navigationItem.title = peerID.displayName
            messages = [JSQMessage]()
        }
        else {
            channel.delegate = self
            channel.subscribeToChannel()
            // set up user info from facebook login details
            senderId = user?.email
            senderDisplayName = user?.name
        }
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
    
//      USEFUL CODE FOR GROUP CHATS; LABELS EACH MESSAGE WITH WHOEVER IS MESSAGING FROM IT
//    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
//        
//        let data = self.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
//        
//        if (self.senderDisplayName == data.senderDisplayName()) {
//            return nil
//        }
//        return NSAttributedString(string: data.senderDisplayName())
//    }
//    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
//        
//        let data = self.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
//        
//        if (self.senderDisplayName == data.senderDisplayName()) {
//            return 0.0
//        }
//        return kJSQMessagesCollectionViewCellLabelHeightDefault
//    }
}

//MARK - Toolbar
extension MessagesViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        // Create msg and add to messages array
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        // Add to core data if not a bluetooth message
        if cameFromDiscover == false {
            let messageID = chatLog.chatLogID
            storeMessage(message.senderId, senderDisplayName: message.senderId, date: message.date!, text: message.text, messageID: messageID!, inContext: self.appDelegate.coreDataStack.mainQueueContext)
        }
        
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
        messageToSend.senderDisplayName = self.senderDisplayName
        messageToSend.recipientId = chatLog.recipientEmail!
        messageToSend.channel = syncanoChannelName
        messageToSend.other_permissions = .Full
        
        messageToSend.saveWithCompletionBlock { error in
            if (error != nil) {
                // Error handling
            }
        }
    }
    
    func downloadNewestMessagesFromSyncano() {
        
        // Have to only update relevant msgs, so we go to bottom method and tweak it
        Message.please().giveMeDataObjectsWithCompletion { objects, error in
            
            if let messages = objects as? [Message] {
                
                self.messages = self.jsqMessagesFromSyncanoMessages(messages)
                self.finishReceivingMessage()
            }
            
        }
    }
    
    func jsqMessagesFromSyncanoMessages(messages: [Message]) -> [JSQMessage] {
        var jsqMessages: [JSQMessage] = []
        
        for message in messages {
            // First check gets our own messages, second check gets messages addressed to us only
            if message.senderId == self.senderId || message.recipientId == self.senderId {
                jsqMessages.append(self.jsqMessageFromSyncanoMessage(message))
            }
        }
        
        return jsqMessages
    }
    
    func jsqMessageFromSyncanoMessage(message: Message) -> JSQMessage {

        let jsqMessage = JSQMessage(senderId: message.senderId, senderDisplayName: message.senderDisplayName, date: message.created_at, text: message.text)
        
        // Add to core data
        let messageID = chatLog.chatLogID
        storeMessage(message.senderId, senderDisplayName: message.senderDisplayName, date: message.created_at!, text: message.text, messageID: messageID!, inContext: self.appDelegate.coreDataStack.mainQueueContext)
        
        if chatLog.recipientName == "" && chatLog.recipientEmail == message.senderId {
            chatLog.recipientName = message.senderDisplayName
            navigationItem.title = chatLog.recipientName
        }
        
        return jsqMessage
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
        
        let msg = jsqMessageFromSyncanoMessage(message!)

        // If the message is addressed to us, receive it
        if message!.recipientId == self.senderId {
            self.messages.append(msg)
        }
        else {
            // If we get here, we add the message to the proper chatLog or create a new one if chatlog doesn't exist
            // TODO
        }
        
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

//MARK - CoreData

extension MessagesViewController {
    
    // When called from 'new chat' button, do this: makeNewChatLog(.., .., .., self.coreDataStack.mainQueueContext)
    // Store a JSQMessage in core data
    func storeMessage(senderID: String, senderDisplayName: String, date: NSDate, text: String, messageID: String, inContext context: NSManagedObjectContext) {
        
        var chatMessage: ChatMessage!
        context.performBlockAndWait() {
            chatMessage = NSEntityDescription.insertNewObjectForEntityForName("ChatMessage", inManagedObjectContext: context) as! ChatMessage
            chatMessage.senderID = senderID
            chatMessage.senderDisplayName = senderDisplayName
            chatMessage.date = date
            chatMessage.text = text
            chatMessage.messageID = messageID
        }
    }
    
    // Commented out stuff is for sorting the messages (ignore for now)
    func saveChatMessageChanges() {
        
//        let mainQueueContext = appDelegate.coreDataStack.mainQueueContext
//        mainQueueContext.performBlockAndWait() {
//            try! mainQueueContext.obtainPermanentIDsForObjects(self.chatMessages)
//        }
//        let objectIDs = chatMessages.map{ $0.objectID}
//        let predicate = NSPredicate(format: "self IN %@", objectIDs)
//        let sortByDateReceived = NSSortDescriptor(key: "date", ascending: true)
        
        do {
            try appDelegate.coreDataStack.saveChanges()
            
//            try self.fetchMainQueueChatMessages(predicate: predicate, sortDescriptors: [sortByDateReceived])
//            result = .Success(mainQueueChatLogs)
        }
        catch let error {
            print("saving to core data failed with: \(error)")
        }
    }
    
    // Update our chatlog array
    func fetchMainQueueChatMessages(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [ChatMessage] {
        
        let fetchRequest = NSFetchRequest(entityName: "ChatMessage")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = appDelegate.coreDataStack.mainQueueContext
        var mainQueueChatMessages: [ChatMessage]?
        var fetchRequestError: ErrorType?
        mainQueueContext.performBlockAndWait() {
            do {
                mainQueueChatMessages = try mainQueueContext.executeFetchRequest(fetchRequest) as? [ChatMessage]
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        guard let chatMessages = mainQueueChatMessages else {
            throw fetchRequestError!
        }
        
        return chatMessages
    }
    
    //put this shit in viewdidload
    func loadChatMessages() {
        let sortByDateTaken = NSSortDescriptor(key: "date", ascending: true)
        let allChatMessages = try! self.fetchMainQueueChatMessages(predicate: nil, sortDescriptors: [sortByDateTaken])
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.chatMessages = allChatMessages
            // refresh table view here
        }
    }

    
}














