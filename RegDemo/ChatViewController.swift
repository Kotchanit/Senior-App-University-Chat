//
//  ChatViewController.swift
//  RegDemo
//
//  Created by B13 on 7/20/2560 BE.
//  Copyright © 2560 Apptitude. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Alamofire
import AlamofireImage

class ChatViewController: JSQMessagesViewController {
    
    var chatroomID = "news"
    var name = ""
    var messages = [JSQMessage]()
    
    var messageRef: DatabaseReference?
    var chatRef: DatabaseReference?
    var members: [String] = []
    
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var avatars = [String: JSQMessagesAvatarImage]()
    private let imageURLNotSetKey = "NOTSET"
    private let messageQueryLimit: UInt = 25
    var avatarString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputToolbar.isHidden = true
        
        
        senderId = AuthenticationManager.user()?.uid
        senderDisplayName = AuthenticationManager.user()?.name
        
        Database.database().reference().child("users").child(senderId).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            if let name = snapshot.value as? String {
                self.senderDisplayName = name
            }
        })
        chatRef = Database.database().reference().child("chatrooms").child(chatroomID)
        messageRef = Database.database().reference().child("chatrooms").child(chatroomID).child("messages")
        observeMessages()
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height: kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView.collectionViewLayout.outgoingAvatarViewSize = .zero
        collectionView.collectionViewLayout.bubbleSizeCalculator = MessagesBubblesWithEmojiSizeCalculator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        automaticallyScrollsToMostRecentMessage = true
        observeMembers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editVC = segue.destination as? EditViewController {
            editVC.chatroomID = chatroomID
        }
    }
    
    func observeMembers() {
        Database.database().reference().child("chatrooms").child(chatroomID).child("members").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.members = [String](dictionary.keys)
                if self.chatroomID == "news" {
                    self.navigationItem.title = "\(self.name)"
                } else {
                    self.navigationItem.title = "\(self.name)(\(self.members.count))"
                }
                self.inputToolbar.isHidden = !self.members.contains(self.senderId)
            }
        })
        Database.database().reference().child("chatrooms").child(chatroomID).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            if let name = snapshot.value as? String{
                self.name = name
                if self.chatroomID == "news" {
                    self.navigationItem.title = "\(self.name)"
                } else {
                    self.navigationItem.title = "\(self.name)(\(self.members.count))"
                }
            }
        })
    }
    
    func observeMessages() {
        messageRef!.observe(.childAdded, with: { snapshot in
            //print(snapshot.value!)
            if let dict = snapshot.value as? [String: AnyObject] {
                let mediaType = dict["mediaType"] as! String
                let senderId = dict["senderID"] as! String
                let senderName = dict["senderName"] as! String
                let timestampRaw = dict["timestamp"] as? String ?? ""
                let timestamp = Date(iso8601: timestampRaw) ?? Date()
                
                switch mediaType {
                    
                case "TEXT":
                    
                    let text = dict["text"] as? String
                    self.messages.append(JSQMessage(senderId: senderId, senderDisplayName: senderName, date: timestamp, text: text))
                    self.downloadAvatar(for: senderId, avatarImage: self.prepareAvatarImage(id: senderId, with: senderName))
                    
                case "PHOTO":
                    
                    let fileUrl = dict["fileUrl"] as! String
                    let url = NSURL(string: fileUrl)
                    let data = NSData(contentsOf: url! as URL)
                    let picture = UIImage(data: data! as Data)
                    let photo = JSQPhotoMediaItem(image: picture)
                    self.messages.append(JSQMessage(senderId: senderId, senderDisplayName: senderName, date: timestamp, media: photo))
                    self.downloadAvatar(for: senderId, avatarImage: self.prepareAvatarImage(id: senderId, with: senderName))
                    if self.senderId == senderId {
                        photo?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        photo?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    
                case "VIDEO":
                    
                    let fileUrl = dict["fileUrl"] as! String
                    let video = NSURL(string: fileUrl)
                    let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
                    self.messages.append(JSQMessage(senderId: senderId,senderDisplayName: senderName, date: timestamp, media: videoItem))
                    self.downloadAvatar(for: senderId, avatarImage: self.prepareAvatarImage(id: senderId, with: senderName))
                    if self.senderId == senderId {
                        videoItem?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        videoItem?.appliesMediaViewMaskAsOutgoing = false
                    }

                default :
                    print("unknown data type")
                }
                
                self.collectionView.reloadData()
               
            }
             self.finishReceivingMessage()
        })
    }
    
    //sender TextMessages
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let newMessage = messageRef!.childByAutoId()
        if chatroomID == "news" {
            let messageData = [
                "text": text,
                "senderID": senderId,
                "senderName": "Naresuan University",
                "mediaType": "TEXT",
                "timestamp": Date().iso8601DateString]
            newMessage.setValue(messageData)
        } else {
            let messageData = [
                "text": text,
                "senderID": senderId,
                "senderName": senderDisplayName,
                "mediaType": "TEXT",
                "timestamp": Date().iso8601DateString]
            newMessage.setValue(messageData)
        }
        chatRef?.child("lastest_message").setValue(text)
        chatRef?.child("lastest_message_timestamp").setValue(Date().iso8601DateString)
        self.finishSendingMessage()
    }
    
    //Sender MediaMessages
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("didPressAccessoryButton")
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction) in
            
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (alert : UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        let videoLibrary = UIAlertAction(title: "Video Library", style: .default) { (alert : UIAlertAction) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func getMediaFrom(type: CFString) {
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    //Display Messages
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            let bubbleFactory = JSQMessagesBubbleImageFactory()
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.orange)
        } else {
            let bubbleFactory = JSQMessagesBubbleImageFactory()
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.lightGray)
        }
    }
    
    //MARK setting messageBubbletopLabel about name
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]

        if message.senderId == senderId {
            return nil
        } else {
            guard let senderDisplayName = message.senderDisplayName else {
                return nil
            }
            return NSAttributedString(string: senderDisplayName)

        }
    }
    
    //messageBubbleTopLabel hight
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if messages.count == 0 {
            return 0.0
        }
        if messages[indexPath.item].senderId == senderId {
            return 8.0
        }

        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    //messageBubbleTopLabel text about Date
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if cellHasTopLabelAt(indexPath: indexPath) {
            return NSAttributedString(string: "\(messages[indexPath.item].date.chatFormatString)")
        }
        return nil
    }
    
    //set hight toplabel
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if cellHasTopLabelAt(indexPath: indexPath) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    private func cellHasTopLabelAt(indexPath: IndexPath) -> Bool {
        if indexPath.item == 0 {
            return true
        }
        
        let thisMessage = messages[indexPath.item]
        let prevMessage = messages[indexPath.item-1]
        return thisMessage.date.timeIntervalSince(prevMessage.date) > 3600
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        if messages.count == 0 {
            return nil
        }
        
        let message = messages[indexPath.item]
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: message.date)
        let minute = calendar.component(.minute, from: message.date)
        let cellBottomLabelText = String(format: "%02d:%02d", hour, minute)
        
        return NSAttributedString(string: cellBottomLabelText)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    //Show user's pic in chatroom for each message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        if chatroomID == "news" {
            return JSQMessagesAvatarImage.avatar(with: #imageLiteral(resourceName: "nu-logo"))
        } else {
            let message = messages[indexPath.item]
            return prepareAvatarImage(id: message.senderId, with: message.senderDisplayName)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    //set text color -> toplabel in bubble
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if !message.isMediaMessage {
            cell.textView.isUserInteractionEnabled = true
            if message.text.unicodeScalars.count == 1 && message.text.unicodeScalars.first!.isEmoji {
                cell.textView.font = UIFont.systemFont(ofSize: 72)
                cell.messageBubbleImageView.isHidden = true
            }
            else {
                cell.textView.font = UIFont.systemFont(ofSize: 17)
                cell.messageBubbleImageView.isHidden = false
            }
        }

        if message.senderId != senderId {
            cell.messageBubbleTopLabel.textColor = UIColor.darkGray
        }

        cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0, kJSQMessagesCollectionViewAvatarSizeDefault+8, 10, 0)
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("didTapMessageBubbleAt indexPath: \(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
            let player = AVPlayer(url: mediaItem.fileURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player //command to play video
            self.present(playerViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func sendMedia(picture: UIImage?, video: NSURL?) {

        print(Storage.storage().reference())
        if let picture = picture {
            let filePath = "\(Auth.auth().currentUser!)/\(Date.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            Storage.storage().reference().child(filePath).putData(data!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef!.childByAutoId()
                
                if self.chatroomID == "news" {
                    let messageData =
                        ["fileUrl": fileUrl,
                         "senderID": self.senderId,
                         "senderName": "Naresuan University",
                         "mediaType": "PHOTO",
                         "timestamp": Date().iso8601DateString]
                     newMessage.setValue(messageData)
                } else {
                    let messageData =
                        ["fileUrl": fileUrl,
                         "senderID": self.senderId,
                         "senderName": self.senderDisplayName,
                         "mediaType": "PHOTO",
                         "timestamp": Date().iso8601DateString]
                    newMessage.setValue(messageData)
                }
                
                self.chatRef?.child("lastest_message").setValue(self.senderDisplayName + " send photo")
                self.chatRef?.child("lastest_message_timestamp").setValue(Date().iso8601DateString)
            }
            
        } else if let video = video {
            let filePath = "\(Auth.auth().currentUser!)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = NSData(contentsOf: video as URL)
            let metadata = StorageMetadata()
            metadata.contentType = "video/mp4"
            Storage.storage().reference().child(filePath).putData(data! as Data, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef!.childByAutoId()
                
                if self.chatroomID == "news" {
                    let messageData =
                        ["fileUrl": fileUrl,
                        "senderID": self.senderId,
                        "senderName": "Naresuan University",
                        "mediaType": "VIDEO",
                        "timestamp": Date().iso8601DateString]
                        newMessage.setValue(messageData)
                } else {
                    let messageData =
                        ["fileUrl": fileUrl,
                         "senderID": self.senderId,
                         "senderName": self.senderDisplayName,
                         "mediaType": "VIDEO",
                         "timestamp": Date().iso8601DateString]
                        newMessage.setValue(messageData)
                }
                
                self.chatRef?.child("lastest_message").setValue(self.senderDisplayName + " send video")
                self.chatRef?.child("lastest_message_timestamp").setValue(Date().iso8601DateString)
                
            }
        }
        finishSendingMessage()
      
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        Alamofire.request(photoURL).responseImage { response in
            if let image = response.value {
                mediaItem.image = image
            }
            
            self.finishReceivingMessage()
            guard let key = key else { return }
            self.photoMessageMap.removeValue(forKey: key)
        }
    }
    
    
    private func reloadRows(with senderID: String) {
        let rows = collectionView.indexPathsForVisibleItems.filter { (indexPath) -> Bool in
            let data = collectionView.dataSource.collectionView(collectionView, messageDataForItemAt: indexPath)
            return data?.senderId() == senderID
        }
        collectionView.reloadItems(at: rows)
    }
    
    private func downloadAvatar(for senderID: String, avatarImage: JSQMessagesAvatarImage) {
        guard let token = AuthenticationManager.token(), let request = API.userImageURLRequest(token: token, userID: senderID) else {
            return
        }
        
        Alamofire.request(request).responseImage { response in
            if let image = response.value {
                avatarImage.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                self.reloadRows(with: senderID)
            }
        }
    }
    
    private func prepareAvatarImage(id: String, with name: String) -> JSQMessagesAvatarImage! {
        
        if (self.avatars[id] == nil) {
            let firstChar = String(name.characters.first!)
            let avartarImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: firstChar , backgroundColor: UIColor.groupTableViewBackground, textColor: UIColor.lightGray, font: UIFont.systemFont(ofSize: 17), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            self.avatars[id] = avartarImage
        }
        
        return self.avatars[id]
    }
    
    @IBAction func editChatname(_ sender: Any) {
        presentAlert()
    }
    
    func presentAlert() {
        
        let alertController = UIAlertController(title: "Chat name", message: "Please input your chat name", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                self.navigationItem.title = "\(field.text!) (\(self.members.count))"
                let chatname = field.text
                let dataRef = Database.database().reference().child("chatrooms").child(self.chatroomID).child("name")
                dataRef.setValue(chatname)
            } else {
                // user did not fill field
            }
        }
    
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Chat name"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
//    @IBAction func DidPreessed(_ sender: Any) {
//        if let tabbarVC = self.tabBarController, let vc = self.storyboard?.instantiateViewController(withIdentifier: "contactVC") {
//            if (tabbarVC.viewControllers?.count ?? 0) < 2 { return }
//            guard let desMavVC = tabbarVC.viewControllers?[1] as? UINavigationController else { return }
//            vc.hidesBottomBarWhenPushed = true
//            desMavVC.pushViewController(vc, animated: true)
//            self.navigationController?.popToRootViewController(animated: false)
//            tabbarVC.selectedIndex = 1
//        }
//
//    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish picking")
        //get the image
        print(info)
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //photo
            sendMedia(picture: picture, video: nil)

        } else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
            //video
            sendMedia(picture: nil, video: video)
        }
        
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
        
    }
}
