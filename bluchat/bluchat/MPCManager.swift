//
//  MPCManager.swift
//  bluchat
//
//  Created by Hamza Muhammad on 8/3/16.
//  Copyright © 2016 Hamza Muhammad. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import JSQMessagesViewController

protocol MPCManagerDelegate {
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool, MCSession)->Void)?
    
    var delegate: MPCManagerDelegate?
    
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "bluchat-mpc")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "bluchat-mpc")
        advertiser.delegate = self
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        
        delegate?.foundPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerate() {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        
        delegate?.lostPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print(error.localizedDescription)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let receivedMessage = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! JSQMessage
        NSNotificationCenter.defaultCenter().postNotificationName("receivedMPCDataNotifcation", object: receivedMessage)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state {
        case MCSessionState.Connected:
            print("Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID)
        
        case MCSessionState.Connecting:
            print("Connecting to session: \(session)")
            
        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool,
        MCSession) -> Void) {
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(error.localizedDescription)
    }
    
    // may have to fix this method
    func sendData(messageToSend sentMsg: JSQMessage, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(sentMsg)
        let peersArray = NSArray(object: targetPeer)
        
        do {
            try session.sendData(dataToSend, toPeers: peersArray as! [MCPeerID], withMode: MCSessionSendDataMode.Reliable)
        }
        catch {
            print("Error while sending data")
        }
        
        return true
    }
}
