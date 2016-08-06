//
//  Message.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/6/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import syncano_ios

class Message: SCDataObject {
    var text = ""
    var senderId = ""
    var attachment: SCFile?
    
    override class func extendedPropertiesMapping() -> [NSObject: AnyObject] {
        return [
        "senderId":"senderid"]
    }
}
