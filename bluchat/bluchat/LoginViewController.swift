//
//  LoginViewController.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/6/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    // This class will login user into facebook!
    
    var userName: NSString?
    var userEmail: NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.performSegueWithIdentifier("ShowMain", sender: self)
            }
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
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
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile")
            {
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                    self.performSegueWithIdentifier("ShowMain", sender: self)
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func assignUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                self.userName = result.valueForKey("name") as? NSString
                print("User Name is: \(self.userName)")
                self.userEmail = result.valueForKey("email") as? NSString
                print("User Email is: \(self.userEmail)")
            }
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
            
        }
    }
    
    
    
}