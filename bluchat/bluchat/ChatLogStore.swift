//
//  ChatLogStore.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/3/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class ChatLogStore {
    
    var allChatLogs = [ChatLog]()
    
    let chatLogArchiveURL: NSURL = {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.URLByAppendingPathComponent("chatlogs.archive")
    }()
    
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
    
    func findChatLogWithRecipientName(recipientName: String) -> ChatLog {
        
        for chatLog in allChatLogs {
            if chatLog.recipientName == recipientName {
                return chatLog
            }
        }
        
        // Since we got here, we have to make a new chatlog with this info:
        let newChatLog = ChatLog(recipientName: recipientName, lastMessageRecieved: nil)
        allChatLogs.append(newChatLog)
        return newChatLog
    }
    
    init() {
        if let archivedItems = NSKeyedUnarchiver.unarchiveObjectWithFile(chatLogArchiveURL.path!) as? [ChatLog] {
            allChatLogs += archivedItems
        }
//        for _ in 0..<5 {
//            let chatLog = ChatLog(recipientName: "asdf", lastMessageRecieved: "test123")
//            allChatLogs.append(chatLog)
//        }
    }
    
    func saveChanges() -> Bool {
        print("Savings chat logs to: \(chatLogArchiveURL.path!)")
        return NSKeyedArchiver.archiveRootObject(allChatLogs, toFile: chatLogArchiveURL.path!)
    }

}
