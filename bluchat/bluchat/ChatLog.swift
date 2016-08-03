//
//  ChatLog.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/3/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatLog: NSObject {
    
    var recipientName: String
    var lastMessageReceived: String?
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
        
        super.init()
    }
    
}
