//
//  ChatLog.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/7/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import Foundation
import CoreData


class ChatLog: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Give the properties their initial values
        recipientEmail = ""
        recipientName = ""
        lastMessageReceived = ""
        lastMessageTime = NSDate()
        chatLogID = ""
    }
}
