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
    
    func setupPeerAndSessionWithDisplayName(_ displayName: String) {
        peerID = MCPeerID(displayName: displayName)
        session = MCSession(peer: peerID!)
        session?.delegate = self
    }
    
    func setupMCBrowser() {
        browser = MCBrowserViewController(serviceType: "chat-files", session: session!)
    }
    
    func advertiseSelf(_ shouldAdvertise: Bool) {
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
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let dict = [
            "peerID": peerID,
            "state": state.hashValue
        ] as [String : Any]

        debugPrint("didChangeState")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MCDidChangeStateNotification"), object: nil, userInfo: dict)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dict = [
            "data": data,
            "peerID": peerID
        ] as [String : Any]
        debugPrint("didReceiveData")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MCDidReceiveDataNotification"), object: nil, userInfo: dict)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        let dict = [
            "resourceName": resourceName,
            "peerID": peerID,
            "progress": progress
        ] as [String : Any]
        debugPrint("didStartReceivingResourceWithName")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MCDidStartReceivingResourceNotification"), object: nil, userInfo: dict)
        
        DispatchQueue.main.async(execute: {
            progress.addObserver(self, forKeyPath: "fractionCompleted", options: [.new], context: nil)
        })
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        let dict = [
            "resourceName": resourceName,
            "peerID": peerID,
            "localURL": localURL
        ] as [String : Any]
        debugPrint("didFinishReceivingResourceWithName")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MCDidFinishReceivingResourceNotification"), object: nil, userInfo: dict)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // empty, no methods are needed in this function
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "MCReceivingProgressNotification"), object: nil, userInfo: [
                "progress": Progress()
            ])
    }
    
    
}
