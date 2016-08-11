//
//  ChatLogCell.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/3/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatLogCell: UITableViewCell {
    
    @IBOutlet var recipientNameLabel: UILabel!
    @IBOutlet var lastMessageReceivedLabel: UILabel!
    @IBOutlet var lastMessageTimeLabel: UILabel!
    @IBOutlet var notificationLabel: UIImageView!
}