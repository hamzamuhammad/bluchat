//
//  DiscoverViewController.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/4/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class DiscoverViewController: UITableViewController, MPCManagerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isAdvertising: Bool!
    
    @IBOutlet var startStopAdvertisingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Have to load data we get from MPC here
        
        
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
            }
            else {
                self.appDelegate.mpcManager.advertiser.startAdvertisingPeer()
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
    
}

