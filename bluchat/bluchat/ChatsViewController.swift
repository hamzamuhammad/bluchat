//
//  ChatsViewController.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/3/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import syncano_ios
import CoreData

class ChatsViewController: UITableViewController {
    
    // Reference to appDelegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Main data source
    var chatLogStore: [ChatLog]!
    
    // Format an NSDate object
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatLogStore.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get new or recycled cell
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatLogCell", forIndexPath: indexPath) as! ChatLogCell
        
        // Set details for cell
        let chatLog = chatLogStore[indexPath.row]
        
        cell.recipientNameLabel.text = chatLog.recipientName
        cell.lastMessageReceivedLabel.text = chatLog.lastMessageReceived
        cell.lastMessageTimeLabel.text = dateFormatter.stringFromDate(chatLog.lastMessageTime)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        
        loadChatLogs()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let chatLog = chatLogStore[indexPath.row]
            
            let title = "Delete \(chatLog.recipientName)'s chat log?"
            let message = "Are you sure you want to delete this chat log?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
                (action) -> Void in
                self.chatLogStore.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            })
            ac.addAction(deleteAction)
            
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    // TODO HAVE TO IMPLEMENT THIS METHOD
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // chatLogArchive.moveChatLogAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowMessages" {
            if let row = tableView.indexPathForSelectedRow?.row {
                
                
                // Here, we get the required messages from a ChatLog obj
                let chatLog = chatLogStore[row]
                
                let messagesViewController = segue.destinationViewController as! MessagesViewController
                messagesViewController.chatLog = chatLog
                messagesViewController.cameFromDiscover = false
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    
    // When called from 'new chat' button, do this: makeNewChatLog(.., .., .., self.coreDataStack.mainQueueContext)
    func makeNewChatLog(recipientName: String, lastMessageReceived: String, lastMessageTime: NSDate, chatLogID: String, inContext context: NSManagedObjectContext) -> ChatLog {
        
        let fetchRequest = NSFetchRequest(entityName: "ChatLog")
        let predicate = NSPredicate(format: "chatLogID == \(chatLogID)")
        fetchRequest.predicate = predicate
        
        var fetchedChatLogs: [ChatLog]!
        context.performBlockAndWait() {
            fetchedChatLogs = try! context.executeFetchRequest(fetchRequest) as! [ChatLog]
        }
        if fetchedChatLogs.count > 0 {
            return fetchedChatLogs.first!
        }
        
        var chatLog: ChatLog!
        context.performBlockAndWait() {
            chatLog = NSEntityDescription.insertNewObjectForEntityForName("ChatLog", inManagedObjectContext: context) as! ChatLog
            chatLog.recipientName = recipientName
            chatLog.lastMessageReceived = lastMessageReceived
            chatLog.lastMessageTime = lastMessageTime
            chatLog.chatLogID = chatLogID
        }
        
        return chatLog
    }
    
    func saveChatLogChanges() {
        
        let mainQueueContext = appDelegate.coreDataStack.mainQueueContext
        mainQueueContext.performBlockAndWait() {
            try! mainQueueContext.obtainPermanentIDsForObjects(self.chatLogStore)
        }
        let objectIDs = chatLogStore.map{ $0.objectID}
        let predicate = NSPredicate(format: "self IN %@", objectIDs)
        let sortByDateReceived = NSSortDescriptor(key: "lastMessageTime", ascending: true)
        
        do {
            try appDelegate.coreDataStack.saveChanges()
            
            try self.fetchMainQueueChatLogs(predicate: predicate, sortDescriptors: [sortByDateReceived])
            //result = .Success(mainQueueChatLogs)
        }
        catch let error {
            print("saving to core data failed with: \(error)")
        }
    }
    
    // Update our chatlog array
    func fetchMainQueueChatLogs(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [ChatLog] {
        
        let fetchRequest = NSFetchRequest(entityName: "ChatLog")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = appDelegate.coreDataStack.mainQueueContext
        var mainQueueChatLogs: [ChatLog]?
        var fetchRequestError: ErrorType?
        mainQueueContext.performBlockAndWait() {
            do {
                mainQueueChatLogs = try mainQueueContext.executeFetchRequest(fetchRequest) as? [ChatLog]
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        guard let chatLogStore = mainQueueChatLogs else {
            throw fetchRequestError!
        }
        
        return chatLogStore
    }
    
    //put this shit in viewdidload
    func loadChatLogs() {
        let sortByDateTaken = NSSortDescriptor(key: "lastMessageTime", ascending: true)
        let allChatLogs = try! self.fetchMainQueueChatLogs(predicate: nil, sortDescriptors: [sortByDateTaken])
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.chatLogStore = allChatLogs
            // refresh table view here
        }
    }
}



























