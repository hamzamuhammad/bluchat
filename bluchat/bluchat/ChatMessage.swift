//
//  ChatMessage.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/7/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import Foundation
import CoreData


class ChatMessage: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Give the properties their initial values
        senderID = ""
        senderDisplayName = ""
        date = NSDate()
        text = ""
        messageID = ""
    }
}
