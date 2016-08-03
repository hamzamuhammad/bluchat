//
//  ChatsViewController.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/3/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class ChatsViewController: UITableViewController {
    
    var chatLogStore: ChatLogStore!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatLogStore.allChatLogs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get new or recycled cell
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        
        // Set details for cell
        let chatLog = chatLogStore.allChatLogs[indexPath.row]
        
        cell.textLabel?.text = chatLog.recipientName
        if let msg = chatLog.lastMessageReceived {
            cell.detailTextLabel?.text = msg
        }
        else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get height of status bar
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
}