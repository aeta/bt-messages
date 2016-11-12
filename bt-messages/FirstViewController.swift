//
//  FirstViewController.swift
//  bt-messages
//
//  Created by alanchu on 5/22/16.
//  Copyright © 2016 Team Auxiliary. All rights reserved.
//

import UIKit
import MultipeerConnectivity


struct Message {
    var isMe: Bool!
    var sender: String!
    var message: String!
    var date: NSDate!
    
    init(sender: String, message: String, isMe: Bool) {
        self.sender = sender
        self.message = message
        self.date = NSDate()
        self.isMe = isMe
        print("creating: \(sender) || message: \(message) || @ \(self.date)")
    }
}

class MessageTableCell: UITableViewCell {
    @IBOutlet var sender: UILabel!
    @IBOutlet var message: UILabel!
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var messages = [Message]()
    
    @IBOutlet var messagesTableView: UITableView! {
        didSet {
            messagesTableView.delegate = self
            messagesTableView.dataSource = self
        }
    }
    
    @IBOutlet var textMessage: UITextField! {
        didSet {
            textMessage.delegate = self
        }
    }
    
    @IBAction func cancelMessage(sender: AnyObject) {
        textMessage.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.didReceiveDataWithNotification(_:)), name: "MCDidReceiveDataNotification", object: nil)
    }
    
    func sendMyMessage() {
        guard let allPeers = appDelegate.mcManager!.session?.connectedPeers else {
            print("Not connected to any devices")
            showError("You don't seem to be connected to any devices 🙁")
            textMessage.resignFirstResponder()
            return
        }
        
        let dataToSend = textMessage.text!.dataUsingEncoding(NSUTF8StringEncoding)
        do {
            try appDelegate.mcManager?.session?.sendData(dataToSend!, toPeers: allPeers, withMode: .Reliable)
        }
        catch {
            debugPrint(error)
            showError("An unexpected error occured while trying to send...")
            textMessage.resignFirstResponder()
            return
        }
        
        messages += [Message(sender: appDelegate.mcManager!.peerID!.displayName, message: textMessage.text!, isMe: true)]
        messagesTableView.reloadData()
        
        textMessage.text = ""
        textMessage.resignFirstResponder()
        
    }
    
    func didReceiveDataWithNotification(notification: NSNotification) {
        let peerID = notification.userInfo!["peerID"] as! MCPeerID
        let peerDisplayName = peerID.displayName

        let receivedData = notification.userInfo!["data"] as! NSData
        let receivedText = NSString(data: receivedData, encoding:NSUTF8StringEncoding) as String?
        
        messages += [Message(sender: peerDisplayName, message: receivedText!, isMe: false)]
        
        performOn(.Main) {
            self.messagesTableView.reloadData()
        }
        
    }
    
    
    // MARK: - UITableViewDelegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableCell") as! MessageTableCell
        
        cell.message.text = messages[indexPath.row].message
        
        if messages[indexPath.row].isMe == true {
            cell.sender.text = "Me"
            cell.sender.textAlignment = .Right
            cell.message.textAlignment = .Right
            cell.sender.textColor = UIColor(red:0.96, green:0.97, blue:0.74, alpha:1.0)
            cell.message.textColor = UIColor(red:0.96, green:0.97, blue:0.74, alpha:1.0)
            
            cell.backgroundColor = UIColor(red:0.50, green:0.74, blue:0.64, alpha:1.0)
        }
        else {
            cell.sender.text = messages[indexPath.row].sender
            cell.sender.textColor = UIColor(red:0.50, green:0.74, blue:0.64, alpha:1.0)
            cell.message.textColor = UIColor(red:0.50, green:0.74, blue:0.64, alpha:1.0)
            
            cell.backgroundColor = UIColor(red:0.96, green:0.97, blue:0.74, alpha:1.0)
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
}

extension FirstViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendMyMessage()
        return true
    }
}
