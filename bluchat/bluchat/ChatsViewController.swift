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
import JSQMessagesViewController

class ChatsViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    // Reference to appDelegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Main data source
    var chatLogStore: [ChatLog]!
    
    // Search bar
    var searchController: UISearchController!
    
    // Format an NSDate object
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    // Temp var for new chatlog email addresss
    var newrecipientEmail: String?
    
    // What userEmail is
    var user: User?
    
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
        cell.lastMessageTimeLabel.text = dateFormatter.stringFromDate(chatLog.lastMessageTime!)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If we already have a search bar
        if let sC = searchController {
            sC.active = true
        }
        else {
            // Make a search bar that the user can enter in an email address to message
            self.searchController = UISearchController(searchResultsController: nil)
            self.searchController.searchResultsUpdater = self
            self.searchController.delegate = self
            self.searchController.searchBar.delegate = self
            
            self.searchController.hidesNavigationBarDuringPresentation = false
            self.searchController.dimsBackgroundDuringPresentation = true
            self.searchController.searchBar.placeholder = "New chat"
            self.searchController.searchBar.searchBarStyle = .Prominent
            
            self.navigationItem.titleView = searchController.searchBar
            
            self.definesPresentationContext = true
        }
        
        
        // Tweak our table cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        
        // Load initial chatlogs
        print("we load chatlogs from viewdidload")
        loadChatLogs()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // Here, we will check if the user entered a valid username and if so we make a chat for them
        newrecipientEmail = searchBar.text!
        SCUser.registerWithUsername(newrecipientEmail!, password: "asdf") { error in
            // If we get in here, it means that the user exists:

            // Segue into a new chat
            self.performSegueWithIdentifier("ShowMessages", sender: self)
            
            // Hide search bar
            self.searchController.active = false
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let chatLog = chatLogStore[indexPath.row]
            
            let name = chatLog.recipientName! as String
            let title = "Delete \(name)'s chat log?"
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
            
            var chatLog: ChatLog?
            if let row = tableView.indexPathForSelectedRow?.row {
                
                // Here, we get the required messages from a ChatLog obj
                chatLog = chatLogStore[row]
            }
            else {
                
                // In this case, there isn't a selected row, so make a new chat
                chatLog = makeNewChatLog(newrecipientEmail!, recipientName: "", lastMessageReceived: "", lastMessageTime: NSDate(), chatLogID: newrecipientEmail!, inContext: appDelegate.coreDataStack.mainQueueContext)
            }
            
            let messagesViewController = segue.destinationViewController as! MessagesViewController
            messagesViewController.chatLog = chatLog
            messagesViewController.cameFromDiscover = false
            messagesViewController.user = user
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("we are in chatsview view will disappear")
        saveChatLogChanges()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        print("we are in chatsview view will appear")
//        loadChatLogs()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    
    // When called from 'new chat' button, do this: makeNewChatLog(.., .., .., self.coreDataStack.mainQueueContext)
    func makeNewChatLog(recipientEmail: String, recipientName: String, lastMessageReceived: String, lastMessageTime: NSDate, chatLogID: String, inContext context: NSManagedObjectContext) -> ChatLog {
        
        let fetchRequest = NSFetchRequest(entityName: "ChatLog")
        let predicate = NSPredicate(format: "chatLogID LIKE %@", chatLogID)
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
            chatLog.recipientEmail = recipientEmail
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
        print("we are in chatsview loadchatlogs method")
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.chatLogStore = allChatLogs
            for chatlog in self.chatLogStore {
                print("loaded chatlog: \(chatlog.recipientName)")
            }
            // refresh table view here
        }
    }
}



























