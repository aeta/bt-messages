//
//  MCManager.swift
//  bt-messages
//
//  Created by alanchu on 5/21/16.
//  Copyright © 2016 Team Auxiliary. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MCManager: NSObject {
    
    var peerID: MCPeerID?
    var session: MCSession?
    var browser: MCBrowserViewController?
    var advertiser: MCAdvertiserAssistant?
    
    func setupPeerAndSessionWithDisplayName(displayName: String) {
        peerID = MCPeerID(displayName: displayName)
        session = MCSession(peer: peerID!)
        session?.delegate = self
    }
    
    func setupMCBrowser() {
        browser = MCBrowserViewController(serviceType: "chat-files", session: session!)
    }
    
    func advertiseSelf(shouldAdvertise: Bool) {
        if shouldAdvertise {
            advertiser = MCAdvertiserAssistant(serviceType: "chat-files", discoveryInfo: nil, session: session!)
            advertiser!.start()
        }
        else {
            advertiser!.stop()
            advertiser = nil
        }
    }
    
}

extension MCManager: MCSessionDelegate {
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        let dict = [
            "peerID": peerID,
            "state": state.hashValue
        ]
        debugPrint("didChangeState")
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: dict)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let dict = [
            "data": data,
            "peerID": peerID
        ]
        debugPrint("didReceiveData")
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidReceiveDataNotification", object: nil, userInfo: dict)
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        let dict = [
            "resourceName": resourceName,
            "peerID": peerID,
            "progress": progress
        ]
        debugPrint("didStartReceivingResourceWithName")
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidStartReceivingResourceNotification", object: nil, userInfo: dict)
        
        dispatch_async(dispatch_get_main_queue(), {
            progress.addObserver(self, forKeyPath: "fractionCompleted", options: [.New], context: nil)
        })
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        let dict = [
            "resourceName": resourceName,
            "peerID": peerID,
            "localURL": localURL
        ]
        debugPrint("didFinishReceivingResourceWithName")
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidFinishReceivingResourceNotification", object: nil, userInfo: dict)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // empty, no methods are needed in this function
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        NSNotificationCenter.defaultCenter().postNotificationName("MCReceivingProgressNotification", object: nil, userInfo: [
                "progress": NSProgress()
            ])
    }
    
    
}