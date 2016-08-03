//
//  ChatLogStore.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/3/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatLogStore {
    
    var allChatLogs = [ChatLog]()
    
    init() {
        for _ in 0..<5 {
            let chatLog = ChatLog(recipientName: "Hamza", lastMessageRecieved: "test123")
            allChatLogs.append(chatLog)
        }
    }
}
