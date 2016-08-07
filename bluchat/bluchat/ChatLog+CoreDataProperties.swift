//
//  ChatLog+CoreDataProperties.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/7/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ChatLog {

    @NSManaged var recipientName: String
    @NSManaged var lastMessageReceived: String
    @NSManaged var lastMessageTime: NSDate
    @NSManaged var chatLogID: String

}
