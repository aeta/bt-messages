//
//  SettingsViewController.swift
//  bt-messages
//
//  Created by Alan Chu on 11/13/16.
//  Copyright © 2016 Team Auxiliary. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SettingsViewController: UITableViewController {
    enum sections: Int {
        case connections
        case nearbyDevices
        case connectedDevices
    }
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// If this is nil, there is no session :(
    var connectedPeers: [MCPeerID]? {
        get {
            return appDelegate.mcManager?.session?.connectedPeers
        }
    }
    
    @IBAction func backButtonDidPress(_ sender: UIBarButtonItem) {
        if connectedPeers!.count < 1 {
            let alert = UIAlertController(title: "Hey there...", message: "You need to connect to at least one other iPhone or Mac", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    // Connections Section
    @IBOutlet weak var connectedSwitch: UISwitch!
    @IBOutlet weak var discoverableSwitch: UISwitch!
    
    @IBAction func connectedSwitchDidChange(_ sender: UISwitch) {
        if !sender.isOn {
            let alert = UIAlertController(title: "Look out!", message: "This will disconnect you from all devices!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Disconnect", style: .destructive, handler: { alert in
                self.discoverableSwitch.setOn(false, animated: true)
                self.discoverableSwitch.isUserInteractionEnabled = false
                self.appDelegate.mcManager.session!.disconnect()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { alert in
                self.connectedSwitch.setOn(true, animated: true)
            }))
            
            present(alert, animated: true)
        } else {
            discoverableSwitch.setOn(true, animated: true)
            discoverableSwitch.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func discoverableSwitchDidChange(_ sender: UISwitch) {
        appDelegate.mcManager.advertiseSelf(sender.isOn)
        print(sender.isOn)
    }
    
    @IBAction func connectButtonDidPress(_ sender: UIButton) {
        if !connectedSwitch.isOn {
            let alert = UIAlertController(title: "Look out!", message: "If you proceed, you must turn on your connection!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Let's do this", style: .destructive, handler: { alert in
                self.connectedSwitch.setOn(true, animated: true)
                self.openMCBrowser()
            }))
            alert.addAction(UIAlertAction(title: "Never mind", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        } else {
            openMCBrowser()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.mcManager!.advertiseSelf(discoverableSwitch.isOn)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                // Connect to nearby devices
            }
        }
    }
    
    func openMCBrowser() {
        appDelegate.mcManager!.setupMCBrowser()
        appDelegate.mcManager!.browser!.delegate = self
        present(appDelegate.mcManager!.browser!, animated: true, completion: nil)
    }

}

extension SettingsViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.mcManager?.browser?.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.mcManager?.browser?.dismiss(animated: true, completion: nil)
    }
}

class ConnectedPeersTableViewController: UITableView, UITableViewDataSource {
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// If this is nil, there is no session :(
    var connectedPeers: [MCPeerID]? {
        get {
            return appDelegate.mcManager?.session?.connectedPeers
        }
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    fileprivate func configure() {
        dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(ConnectedPeersTableViewController.peerDidChangeStateWithNotification(_:)), name: NSNotification.Name(rawValue: "MCDidChangeStateNotification"), object: nil)
        reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedPeers?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        if connectedPeers == nil {
            cell.textLabel?.text = "No devices found 🙁"
        } else {
            cell.textLabel?.text = connectedPeers![indexPath.row].displayName
        }
        
        return cell
    }
    
    func peerDidChangeStateWithNotification(_ notification: Notification) {
        performOn(.main) {
            self.reloadData()
        }
    }
}
