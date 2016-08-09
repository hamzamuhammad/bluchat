//
//  User.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/8/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    
    var email: String
    var name: String
    
    init(email: String, name: String) {
        self.email = email
        self.name = name
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(name, forKey: "name")
    }
    
    required init(coder aDecoder: NSCoder) {
        email = aDecoder.decodeObjectForKey("email") as! String
        name = aDecoder.decodeObjectForKey("name") as! String
        
        super.init()
    }
    
}
