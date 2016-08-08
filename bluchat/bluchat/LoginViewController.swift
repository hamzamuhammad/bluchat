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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Skip FBLogin if user already logged in
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            fbLoginSuccess = true
        }
        else
        {
            // Set up login button and permissions
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Prevent logout button from appearing instead of segue
        if FBSDKAccessToken.currentAccessToken() != nil || fbLoginSuccess == true {
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
            
        }
    }
    
    
    
}