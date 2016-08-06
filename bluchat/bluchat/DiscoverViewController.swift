//
//  DiscoverViewController.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/4/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DiscoverViewController: UITableViewController, MPCManagerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isAdvertising: Bool!
    var currentPeerID: MCPeerID?
    
    @IBOutlet var startStopAdvertisingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        
        // Get height of status bar and make sure cells dont overlap status bar
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        appDelegate.mpcManager.delegate = self
        appDelegate.mpcManager.browser.startBrowsingForPeers()
        appDelegate.mpcManager.advertiser.startAdvertisingPeer()
        isAdvertising = true
        startStopAdvertisingButton.setTitle("Stop Broadcasting", forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func startStopAdvertising(sender: AnyObject) {
        let ac = UIAlertController(title: "", message: "Change Visibility", preferredStyle: .ActionSheet)
        
        var actionTitle: String
        if (isAdvertising == true) {
            actionTitle = "Make me invisible to others"
        }
        else {
            actionTitle = "Make me visible to others"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let visibilityAction = UIAlertAction(title: actionTitle, style: .Default, handler: {
            (action) -> Void in
            if self.isAdvertising == true {
                self.appDelegate.mpcManager.advertiser.stopAdvertisingPeer()
                self.startStopAdvertisingButton.setTitle("Start Broadcasting", forState: .Normal)
                self.isAdvertising = false
            }
            else {
                self.appDelegate.mpcManager.advertiser.startAdvertisingPeer()
                self.startStopAdvertisingButton.setTitle("Stop Broadcasting", forState: .Normal)
                self.isAdvertising = true
            }
        })
        ac.addAction(visibilityAction)
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func foundPeer() {
        tableView.reloadData()
    }
    
    func lostPeer() {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get new or recycled cell
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row] as MCPeerID
        
        appDelegate.mpcManager.browser.invitePeer(selectedPeer, toSession: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }
    
    func invitationWasReceived(fromPeer: String) {
        let ac = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler!(true, self.appDelegate.mpcManager.session)
        }
        ac.addAction(acceptAction)
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.appDelegate.mpcManager.invitationHandler!(false, self.appDelegate.mpcManager.session)
        }
        ac.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        // Store peerID
        currentPeerID = peerID
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.performSegueWithIdentifier("StartChat", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "StartChat" {
            // First, make a temporary chat
            let chatLog = ChatLog(recipientName: (currentPeerID?.displayName)!, lastMessageRecieved: nil)
            
            // Now, go to new chat:
            let messagesViewController = segue.destinationViewController as! MessagesViewController
            messagesViewController.chatLog = chatLog
        }
    }
    
    
}


















