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
    
    func removeChatLog(chatLog: ChatLog) {
        if let index = allChatLogs.indexOf(chatLog) {
            allChatLogs.removeAtIndex(index)
        }
    }
    
    func moveChatLogAtIndex(fromIndex: Int, toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        let movedChatLog = allChatLogs[fromIndex]
        allChatLogs.removeAtIndex(fromIndex)
        allChatLogs.insert(movedChatLog, atIndex: toIndex)
    }
}
