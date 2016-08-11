//
//  LoginViewController.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/6/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import syncano_ios

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    // This class will login user into facebook!
    
    var fbLoginSuccess = false
    var user: User?
    
    let userArchiveURL: NSURL = {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.URLByAppendingPathComponent("user.archive")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red:0.75, green:0.87, blue:0.94, alpha:1.0)

        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Prevent logout button from appearing instead of segue
        if FBSDKAccessToken.currentAccessToken() != nil || fbLoginSuccess == true {
            
            // Have to load User object from storage and segue to chats main
            loadUser()
            performSegueWithIdentifier("ShowMain", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Facebook Delegate Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // Successful login, and hide button
            fbLoginSuccess = true
            loginButton.hidden = true
            
            // Check if permissions are granted
            if result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile")
            {
                self.getUserEmail {(userEmail, userName, error) -> Void in
                    
                    if error != nil {
                        print("login error: \(error)")
                    }
                    
                    print("email: \(userEmail)")
                    print("name: \(userName)")
                    
                    // Have to put User object in storage
                    self.saveUser(userEmail!, userName: userName!)
                    
                    SCUser.registerWithUsername(userEmail!, password: userName!) { error in
                        print("error registering user: \(error)")
                    }
                    print("registered user!")
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func getUserEmail(completion: (userEmail: String?, userName: String?, error: NSError?) -> Void) {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            var userEmail: String?
            var userName: String?
            
            userEmail = result!.objectForKey("email") as? String
            userName = result!.objectForKey("name") as? String
            
            completion(userEmail: userEmail, userName: userName, error: error)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowMain" {
            //let chatLogStore = nil // FIX THIS PART TO GET CHATSTORE FROM CORE DATA
            
            let tabBarController = segue.destinationViewController as! UITabBarController
            let navController = tabBarController.viewControllers![0] as! UINavigationController
            let chatsViewController = navController.topViewController as! ChatsViewController
            
            // Here, we will retrieve all chat logs from core data and set them to the [ChatLog] array
            try! chatsViewController.chatLogStore = chatsViewController.fetchMainQueueChatLogs(predicate: nil, sortDescriptors: nil)
            chatsViewController.user = user
        }
    }
    
    func saveUser(userEmail: String, userName: String) -> Bool {
        
        // Make new user object, and save that to archive
        user = User(email: userEmail, name: userName)
        print("Saving items to: \(userArchiveURL.path!)")
        return NSKeyedArchiver.archiveRootObject(user!, toFile: userArchiveURL.path!)
    }
    
    func loadUser() {
        
        // Get user object from archive and set it as our current user
        if let archivedUser = NSKeyedUnarchiver.unarchiveObjectWithFile(userArchiveURL.path!) as? User {
            user = archivedUser
        }
        else {
            print("Error loading user!")
        }
    }
    
    
}