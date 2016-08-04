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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load old messages and setup chat
        self.setup()
        if (messages.count > 0) {
            loadMessages()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of resources that can be created
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Here, we 'save' changes to chatLog
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // tableView.reloadData()
        reloadMessagesView()
    }
    
    func setup() {
        senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
    }
    
    func loadMessages() {
        
        for msg in messages {
            messages.append(msg)
        }
        reloadMessagesView()
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
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(message)
        self.finishSendingMessage()
        // We actually send the message here
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        // Ignore for now
    }
}