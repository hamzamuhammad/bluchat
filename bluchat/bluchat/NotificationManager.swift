//
//  NotificationManager.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/10/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import syncano_ios

class NotificationManager: NSObject {
    
    // Reference to appDelegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let channel = SCChannel(name: syncanoChannelName)
    
    var chatsViewController: ChatsViewController?
    
    var isFromMessagesView: Bool?
    
    init(chatsViewController: ChatsViewController) {
        
        self.chatsViewController = chatsViewController
        self.isFromMessagesView = false
        
        super.init()
        
        channel.delegate = self
        channel.subscribeToChannel()
    }
    
}

//MARK - Channels
extension NotificationManager: SCChannelDelegate {
    
    func addMessageFromNotification(notification: SCChannelNotificationMessage) {
        
        let message = Message(fromDictionary: notification.payload!)
        
        addNewChatLog(message!.senderId, chatLogRecipientEmail: message!.recipientId, isFromMessageView: isFromMessagesView!)
    }
    
    func addNewChatLog(senderId: String, chatLogRecipientEmail: String, isFromMessageView: Bool) {
        
        let index = chatsViewController?.doesChatLogExist(chatLogRecipientEmail)
        
        var chatLog: ChatLog!
        
        // If its a new convo
        if index == -1 {
            
            // Make new chatlog
            chatLog = chatsViewController?.makeNewChatLog(senderId, recipientName: "", lastMessageReceived: "", lastMessageTime: NSDate(), chatLogID: chatLogRecipientEmail, inContext: appDelegate.coreDataStack.mainQueueContext)
        }
        else {
            // New message for existing convo, add notification message for that specific index
            chatLog = chatsViewController?.chatLogStore[index!]
        }
        
        // Make notification dot appear
        chatLog.isSeen = false
        
        print("received message, attempting to make notification + chatlog, chatLogStore size: \(chatsViewController?.chatLogStore.count)")
        
        // Show a notification if in message view
        if isFromMessageView == true {
            
            //make the local notification
            let localNotification = UILocalNotification()
            localNotification.fireDate = nil
            localNotification.alertBody = "New message!"
 
            //set the notification
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
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
