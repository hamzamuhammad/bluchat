//
//  ChatMessage+CoreDataProperties.swift
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

extension ChatMessage {

    @NSManaged var senderID: String
    @NSManaged var senderDisplayName: String
    @NSManaged var date: NSDate
    @NSManaged var text: String
    @NSManaged var messageID: String

}
