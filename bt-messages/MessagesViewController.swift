//
//  MessagesViewController.swift
//  bt-messages
//
//  Created by Alan Chu on 11/13/16.
//  Copyright © 2016 Team Auxiliary. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import JSQMessagesViewController

struct Conversation {
    let sender: String
    let id: String?
    let latestMessage: String?
    let isRead: Bool
}

class MessagesViewController: JSQMessagesViewController {
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var messages = [JSQMessage]()
    var conversation: Conversation?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    fileprivate var displayName: String!
    
    override func viewDidLoad() {
        senderId = appDelegate.mcManager!.peerID!.displayName
        senderDisplayName = appDelegate.mcManager!.peerID!.displayName
        // The 2 lines above this comment MUST BE DECLARED BEFORE super.viewDidLoad()
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.didReceiveDataWithNotification(_:)), name: NSNotification.Name(rawValue: "MCDidReceiveDataNotification"), object: nil)
        
        // Create bubbles with trails
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
        
        // No avatars
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        // Beta feature, disable is performance sucks
        collectionView?.collectionViewLayout.springinessEnabled = true
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        
        if appDelegate.mcManager!.session!.connectedPeers.count < 1 {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Settings")
            navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func didReceiveDataWithNotification(_ notification: Notification) {
        let peerID = notification.userInfo!["peerID"] as! MCPeerID
        let peerDisplayName = peerID.displayName
        
        let receivedData = notification.userInfo!["data"] as! Data
        let receivedText = NSString(data: receivedData, encoding:String.Encoding.utf8.rawValue) as String?
        let receivedImage = UIImage(data: receivedData)
        
        if let text = receivedText {
            messages.append(JSQMessage(senderId: peerDisplayName, displayName: peerDisplayName, text: text))
        } else if let image = receivedImage {
            messages.append(JSQMessage(senderId: peerDisplayName, displayName: peerDisplayName, media: JSQPhotoMediaItem(image: image)))
        }

        performOn(.main) {
            self.collectionView?.reloadData()
            self.finishReceivingMessage(animated: true)
        }
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Send photo", style: .default) { (action) in
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.sourceType = .photoLibrary
            
            self.present(vc, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { action in
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.sourceType = .camera
            
            self.present(vc, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(photoAction)
        sheet.addAction(cameraAction)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        sendMessage(text: text)
    }
    
    func sendImage(_ image: UIImage) {
        guard let allPeers = appDelegate.mcManager!.session?.connectedPeers else {
            showError("You don't seem to be connected to any devices 🙁")
            return
        }
        let dataToSend = UIImageJPEGRepresentation(image, 0.3)
        do {
            try appDelegate.mcManager.session?.send(dataToSend!, toPeers: allPeers, with: .reliable)
        } catch {
            debugPrint(error)
            showError(error.localizedDescription)
            return
        }
        
        messages.append(JSQMessage(senderId: appDelegate.mcManager.peerID!.displayName, displayName: appDelegate.mcManager.peerID!.displayName, media: JSQPhotoMediaItem(image: image)))
        
        finishSendingMessage(animated: true)
    }
    
    func sendMessage(text body: String) {
        guard let allPeers = appDelegate.mcManager!.session?.connectedPeers else {
            showError("You don't seem to be connected to any devices 🙁")
            return
        }
        
        let dataToSend = body.data(using: String.Encoding.utf8)
        do {
            try appDelegate.mcManager?.session?.send(dataToSend!, toPeers: allPeers, with: .reliable)
        }
        catch {
            debugPrint(error)
            showError("An unexpected error occured while trying to send...")
            return
        }
        
        messages.append(JSQMessage(senderId: appDelegate.mcManager!.peerID!.displayName, displayName: appDelegate.mcManager!.peerID!.displayName, text: body))
        
        finishSendingMessage(animated: true)
        
    }
    
    //MARK: JSQMessages CollectionView DataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        
        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        // Displaying names above messages
        //Mark: Removing Sender Display Name
        
        if message.senderId == self.senderId {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         */
        
        /**
         *  iOS7-style sender name labels
         */
        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let selectedMessage = self.messages[indexPath.item]
        // only do something if its a media message
        if selectedMessage.isMediaMessage {
            let media = selectedMessage.media as! JSQPhotoMediaItem
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageDetail") as! PhotoDetailViewController
            vc.image = media.image
            vc.modalPresentationStyle = .overFullScreen
            
            present(vc, animated: true, completion: nil)
        }
    }

}

extension MessagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendImage(image)
        } else {
            showError("An unexpected error occured")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
