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
    
    @IBAction func newChat(sender: AnyObject) {
        // Have to have drill down interface to a contacts list of users...
        // For now, just add a new chat to the table
        
        // Retrieve new chat log created (or load old one)
//          let newChatLog = chatLogStore.addNewChat()
        
//        if let index = chatLogStore.allChatLogs.indexOf(newChatLog) {
//            let indexPath = NSIndexPath(forRow: index, inSection: 0)
//            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        }
    }
    
    @IBAction func toggleEditingMode(sender: AnyObject) {
        if editing {
            sender.setTitle("Edit", forState: .Normal)
            setEditing(false, animated: true)
        }
        else {
            sender.setTitle("Done", forState: .Normal)
            setEditing(true, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatLogStore.allChatLogs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get new or recycled cell
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatLogCell", forIndexPath: indexPath) as! ChatLogCell
        
        // Set details for cell
        let chatLog = chatLogStore.allChatLogs[indexPath.row]
        
        cell.recipientNameLabel.text = chatLog.recipientName
        if let msg = chatLog.lastMessageReceived {
            cell.lastMessageReceivedLabel.text = msg
        }
        else {
            cell.lastMessageReceivedLabel.text = ""
        }
        if let time = chatLog.lastMessageTime {
            cell.lastMessageTimeLabel.text = time        }
        else {
            cell.lastMessageTimeLabel.text = ""
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
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let chatLog = chatLogStore.allChatLogs[indexPath.row]
            
            let title = "Delete \(chatLog.recipientName)'s chat log?"
            let message = "Are you sure you want to delete this chat log?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
                (action) -> Void in
                self.chatLogStore.removeChatLog(chatLog)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            })
            ac.addAction(deleteAction)
            
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        chatLogStore.moveChatLogAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMessages" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let chatLog = chatLogStore.allChatLogs[row]
                let messagesViewController = segue.destinationViewController as! MessagesViewController
                messagesViewController.messages = chatLog //IMPORTANT TO FIX THIS PART HERE!
            }
        }
    }
}