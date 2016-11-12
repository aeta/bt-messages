//
//  ConnectionsViewController.swift
//  bt-messages
//
//  Created by alanchu on 5/21/16.
//  Copyright © 2016 Team Auxiliary. All rights reserved.
//
import UIKit
import MultipeerConnectivity

class ConnectionsViewController: UIViewController {
    
    var connectedDevices: [String] = []
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: -  Storyboard Outlets
    @IBOutlet var textName: UITextField!
    @IBOutlet var switchVisible: UISwitch!
    @IBOutlet var tableConnectedDevices: UITableView! {
        didSet {
            tableConnectedDevices.delegate = self
            tableConnectedDevices.dataSource = self
        }
    }
    @IBOutlet var buttonDisconnect: UIButton!
    
    @IBAction func browseForDevices(sender: AnyObject) {
        appDelegate.mcManager!.setupMCBrowser()
        appDelegate.mcManager!.browser!.delegate = self
        self.presentViewController(appDelegate.mcManager!.browser!, animated: true, completion: nil)
    }
    
    @IBAction func toggleVisibility(sender: UISwitch) {
        appDelegate.mcManager!.advertiseSelf(sender.on)
    }
    
    @IBAction func disconnect(sender: AnyObject) {
        appDelegate.mcManager?.session?.disconnect()
        textName.enabled = true
        connectedDevices = []
        tableConnectedDevices.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.mcManager!.setupPeerAndSessionWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mcManager!.advertiseSelf(switchVisible.on)
        
    }
    
    func peerDidChangeStateWithNotification(notification: NSNotification) {
        let peerID = notification.userInfo!["peerID"] as! MCPeerID
        let peerDisplayName = peerID.displayName
        let state = notification.userInfo!["state"]! as! MCSessionState
        
        if state != .Connecting {
            if state == .Connected {
                connectedDevices.append(peerDisplayName)
            }
            else if state == .NotConnected {
                if connectedDevices.count > 0 {
                    let indexOfPeer = connectedDevices.indexOf(peerDisplayName)
                    connectedDevices.removeAtIndex(indexOfPeer!)
                    
                }
            }
            performOn(.Main) {
                self.tableConnectedDevices.reloadData()
            }
            
            let peersExist = appDelegate.mcManager!.session!.connectedPeers.count == 0
            
            buttonDisconnect.enabled = !peersExist
            textName.enabled = peersExist
        }
        
    }

}

extension ConnectionsViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appDelegate.mcManager?.browser?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        appDelegate.mcManager?.browser?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ConnectionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textName.resignFirstResponder()
        
        if switchVisible.on {
            appDelegate.mcManager?.advertiser?.stop()
        }
        appDelegate.mcManager = nil
        
        appDelegate.mcManager?.setupPeerAndSessionWithDisplayName(textField.text!)
        appDelegate.mcManager?.setupMCBrowser()
        appDelegate.mcManager?.advertiseSelf(switchVisible.on)
        
        return true
    }
}

extension ConnectionsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedDevices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "CellIdentifier")
        }
        cell!.textLabel!.text = connectedDevices[indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}
