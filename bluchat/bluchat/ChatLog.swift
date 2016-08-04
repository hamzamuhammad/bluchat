//
//  ChatLog.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/3/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatLog: NSObject, NSCoding {
    
    var recipientName: String
    var lastMessageReceived: String?
    var lastMessageTime: String?
    var messages: [JSQMessage]
    
    init(recipientName: String, lastMessageRecieved: String?) {
        
        self.recipientName = recipientName
        if let msg = lastMessageRecieved {
            self.lastMessageReceived = msg
        }
        else {
            self.lastMessageReceived = nil
        }
        self.messages = [JSQMessage]()
        
        // This part here is temporary, just to check things out
        let sender = "Hamza"
        let messageContent = "test123"
        let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
        self.messages.append(message)
        
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        recipientName = aDecoder.decodeObjectForKey("recipientName") as! String
        if let msg = aDecoder.decodeObjectForKey("lastMessageReceived") {
            lastMessageReceived = msg as? String
        }
        else {
            lastMessageReceived = ""
        }
        if let time = aDecoder.decodeObjectForKey("lastMessageTime") {
            lastMessageTime = time as? String
        }
        else {
            lastMessageTime = ""
        }
        messages = aDecoder.decodeObjectForKey("messages") as! [JSQMessage]
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(recipientName, forKey: "recipientName")
        aCoder.encodeObject(lastMessageReceived, forKey: "lastMessageReceived")
        aCoder.encodeObject(lastMessageTime, forKey: "lastMessageTime")
        aCoder.encodeObject(messages, forKey: "messages")
    }
    
}
