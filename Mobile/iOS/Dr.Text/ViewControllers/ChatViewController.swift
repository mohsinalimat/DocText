 
 
 //  ChatViewController.swift
 //  Dr.Text
 //
 //  Created by SoftSuave on 17/10/16.
 //  Copyright © 2016 SoftSuave. All rights reserved.
 //
 
 import UIKit
 import JSQMessagesViewController
 import AVKit
 import AVFoundation
 import AWSCognitoIdentityProvider
 import AWSSNS
 import MobileCoreServices
 import MediaPlayer
 import SDWebImage
 
 class ChatViewController: JSQMessagesViewController, GalleryItemsDatasource, GalleryDisplacedViewsDatasource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPMediaPickerControllerDelegate, IQAudioRecorderViewControllerDelegate, makePaymentDelegate {
    
    var conversation: Conversation?
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(red: 61/255, green: 133/255, blue: 247/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
    var messages = [Message]()
    var isImage: Bool = true
    var timer: Timer?
    var delegate: dashboardProtocolDelegate?
    var imagePicker = UIImagePickerController()
    let mediaPickerController = MPMediaPickerController(mediaTypes: .any)
    let messageDA = MessageDA()
    var audioFilePath = ""
    var isProgress = false
    var receiverImage: UIImage!
    var lastEvulatedKey = LastEvaluatedKey()
    var selectedIndex: Int?
    var messageLimit = 30
    var messageOffset = 0
    var isMaxMsgLimitAchieved = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setup()
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.currentChatMessages.removeAll()
        self.inputToolbar.contentView!.textView!.text = ""
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(ChatViewController.refresh(sender:)), userInfo: nil, repeats: true)
        
        Utils.sendPendingMessagesToServer()
        addObserver()
        checkInternetConnection()
        
        if messageDA.getMessagesCount(roomId: (conversation?.chatRoomId)!) == 0 {
            self.getAllChatMessagesFromServer()
        } else {
            if conversation!.unreadCount! <= 50 {
                resetOffset()
                self.fetchMessageFromDB()
                self.checkMessageStatus()
                self.getChatMessages(isShowHud: false)
            } else {
                self.getAllChatMessagesFromServer()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        removeObserver()
        stopAllPlayingAudio()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let lastRow: Int = self.collectionView.numberOfItems(inSection: 0) - 1
        let indexPath = IndexPath(row: lastRow, section: 0);
        self.scroll(to: indexPath, animated: false)
    }
    
    func addObserver() {
        let notificationName = Notification.Name("ChatNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.refreshNotification), name: notificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.actionOnRefreshChat), name: Utils.chatRefreshNotification, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ChatNotification"), object: nil);
        NotificationCenter.default.removeObserver(self, name: Utils.chatRefreshNotification, object: nil);
    }
    
    //calling when push notification arrive...
    func refreshNotification() {
        stopAllPlayingAudio()
        resetOffset()
        self.fetchMessageFromDB()
        self.checkMessageStatus()
        self.scrollToBottom(animated: false)
    }
    
    func setBackButton() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackChevron") , style: .plain, target: self, action: #selector(BaseViewController.actionOnBackBtn(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    
    func actionOnBackBtn(sender: UIBarButtonItem) {
        if messages.count != 0 {
            let myDict = ["lastMessage": messages.last!]
            NotificationCenter.default.post(name: Notification.Name("DashboardResentMsgNotification"), object: myDict)
        }
        navigationController!.popViewController(animated: true)
    }
    
    func setup() {
        self.senderId = Utils.getCurrentUser().emailID!
        self.senderDisplayName = Utils.getCurrentUser().firstName! + " " + Utils.getCurrentUser().lastName!
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    func stopAllPlayingAudio() {
        //Stop all the audio playing...
        for message in self.messages {
            if message.message_type == MEDIA_TYPE_AUDIO {
                (message.media_Data as! JSQAudioMediaItem).clearCachedMediaViews()
            }
        }
    }
    
    
    //MARK:- Left & Right button actions
    /***** Right button action ****/
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            
            stopAllPlayingAudio()
            if Utils.getCurrentUser().userRole! != "Doctor" {
                
                var receiverId = String()
                if Utils.getCurrentUser().emailID! == conversation?.doctorId! {
                    receiverId = (conversation?.patientId!)!
                } else {
                    receiverId = (conversation?.doctorId!)!
                }
                
                let messageObj = Message(messageId: "", message: text, messageType: "text", senderId: senderId, roomId: (conversation?.chatRoomId!)!, sendTimeString: Utils.convertStringFromDate(date: date), sendTimeobject: date, receiverId: receiverId, message_status: MESSAGE_STATUS_NOT_SENT, paymentStatus: "Not Paid",transactionId: "nil")
                
                messageDA.addUpdateMessages(message: messageObj)
                self.inputToolbar.contentView!.textView!.resignFirstResponder()
                let sendChatMsgVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "SendChatMsgViewController") as! SendChatMsgViewController
                sendChatMsgVC.conversation = conversation
                sendChatMsgVC.currentMessage = messageObj
                sendChatMsgVC.delegate = self
                self.navigationController?.pushViewController(sendChatMsgVC, animated: true)
                
            } else {
                var receiverId = String()
                if Utils.getCurrentUser().emailID! == conversation?.doctorId! {
                    receiverId = (conversation?.patientId!)!
                } else {
                    receiverId = (conversation?.doctorId!)!
                }
                
                let messageObj = Message(messageId: "", message: text, messageType: "text", senderId: senderId, roomId: (conversation?.chatRoomId!)!, sendTimeString: Utils.convertStringFromDate(date: date), sendTimeobject: date, receiverId: receiverId, message_status: MESSAGE_STATUS_NOT_SENT, paymentStatus: "Paid",transactionId: "nil")
                
                messageDA.addUpdateMessages(message: messageObj)
                self.messages.append(messageObj)
                self.finishSendingMessage()
                
                Utils.sendPendingMessagesToServer()
            }
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    /***** Left button action with supporting methods ****/
    override func didPressAccessoryButton(_ sender: UIButton!) {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            
            self.inputToolbar.contentView!.textView!.resignFirstResponder()
            let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
            
            let captureImageAction = UIAlertAction(title: "Capture Image", style: .default) { (action) in
                self.checkCameraPermission(type: kUTTypeImage as String)
            }
            
            let recordVideoAction = UIAlertAction(title: "Record Video", style: .default) { (action) in
                self.imagePicker.videoMaximumDuration = TimeInterval(300)
                self.checkCameraPermission(type: kUTTypeMovie as String)
            }
            
            let recordAudioAction = UIAlertAction(title: "Record Audio", style: .default) { (action) in
                self.stopAllPlayingAudio()
                self.recordAudioAction()
            }
            
            let existingImageAction = UIAlertAction(title: "Choose Existing Media", style: .default) { (action) in
                self.showImagePickerForChooseExisting()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            sheet.addAction(captureImageAction)
            sheet.addAction(recordVideoAction)
            sheet.addAction(recordAudioAction)
            sheet.addAction(existingImageAction)
            sheet.addAction(cancelAction)
            self.present(sheet, animated: true, completion: nil)
            
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
        
    }
    
    func buildVideoItem(videoUrl: URL) -> JSQVideoMediaItem {
        let videoItem = DrTextJSQVideoMediaItem(fileURL: videoUrl, isReadyToPlay: true)
        return videoItem!
    }
    
    func buildAudioItem(urlString:  String) -> JSQAudioMediaItem {
        let audioData = try? Data(contentsOf: URL(fileURLWithPath: urlString))
        let audioItem = JSQAudioMediaItem(data: audioData)
        return audioItem
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(_ media:JSQMediaItem, mediaData: Data, mediaType: String, mediaURL: URL, thumnailImage: UIImage?) {
        
        if Utils.getCurrentUser().userRole! == "Doctor" {
            
            var receiverId = String()
            if Utils.getCurrentUser().emailID! == self.conversation?.doctorId! {
                receiverId = (self.conversation?.patientId!)!
            } else {
                receiverId = (self.conversation?.doctorId!)!
            }
            
            let sentTime = Date()
            var fileUrl: String? = nil
            var text = ""
            if mediaType == MEDIA_TYPE_VIDEO {
                text = "Send a Video"
                fileUrl = Utils.storeFileToLocal(fileData: mediaData, fileName: Utils.convertStringFromDate(date: sentTime), fileEx: ".mov")!
                fileUrl = "file://\(fileUrl!)"
            } else if mediaType == MEDIA_TYPE_AUDIO {
                text = "Send a Audio"
                fileUrl = mediaURL.absoluteString
            } else if mediaType == MEDIA_TYPE_IMAGE {
                text = "Send an Image"
                fileUrl = mediaURL.absoluteString
            }
            
            let messageObj = Message(messageId: "", message: text, messageType: mediaType, senderId: senderId, roomId: (conversation?.chatRoomId!)!, sendTimeString: Utils.convertStringFromDate(date: sentTime), sendTimeobject: sentTime, media: media, media_Msg_Data: mediaData, mediaUrl: nil, receiverId: receiverId, message_status: MESSAGE_STATUS_NOT_SENT, thumbnailImage: thumnailImage, videoLocalUrl: fileUrl, paymentStatus: "Paid",transactionId: "nil")
            
            messageDA.addUpdateMessages(message: messageObj)
            self.messages.append(messageObj)
            self.finishSendingMessage(animated: true)
            Utils.sendPendingMessagesToServer()
        } else {
            
            var receiverId = String()
            if Utils.getCurrentUser().emailID! == self.conversation?.doctorId! {
                receiverId = (self.conversation?.patientId!)!
            } else {
                receiverId = (self.conversation?.doctorId!)!
            }
            
            let sentTime = Date()
            var fileUrl: String? = nil
            var text = ""
            if mediaType == MEDIA_TYPE_VIDEO {
                text = "Send a Video"
                fileUrl = Utils.storeFileToLocal(fileData: mediaData, fileName: Utils.convertStringFromDate(date: sentTime), fileEx: ".mov")!
                fileUrl = "file://\(fileUrl!)"
            } else if mediaType == MEDIA_TYPE_AUDIO {
                text = "Send a Audio"
                fileUrl = mediaURL.absoluteString
            } else if mediaType == MEDIA_TYPE_IMAGE {
                text = "Send an Image"
                fileUrl = mediaURL.absoluteString
            }
            
            let messageObj = Message(messageId: "", message: text, messageType: mediaType, senderId: senderId, roomId: (conversation?.chatRoomId!)!, sendTimeString: Utils.convertStringFromDate(date: sentTime), sendTimeobject: sentTime, media: media, media_Msg_Data: mediaData, mediaUrl: nil, receiverId: receiverId, message_status: MESSAGE_STATUS_NOT_SENT, thumbnailImage: thumnailImage, videoLocalUrl: fileUrl, paymentStatus: "Not Paid",transactionId: "nil")
            
            messageDA.addUpdateMessages(message: messageObj)
            
            self.inputToolbar.contentView!.textView!.resignFirstResponder()
            let sendChatMsgVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "SendChatMsgViewController") as! SendChatMsgViewController
            sendChatMsgVC.conversation = conversation
            sendChatMsgVC.currentMessage = messageObj
            sendChatMsgVC.delegate = self
            self.navigationController?.pushViewController(sendChatMsgVC, animated: true)
        }
    }
    
    
    //Mark:- JSQCollection view Data source Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = self.messages[indexPath.row]
        
        if message.message_type != MEDIA_TYPE_TEXT {
            if message.media_Data != nil {
                if (message.media_Data as! JSQMediaItem).appliesMediaViewMaskAsOutgoing != self.isOutgoingMsg(senderId: message.sender_Id!) {
                    (message.media_Data as! JSQMediaItem).appliesMediaViewMaskAsOutgoing = self.isOutgoingMsg(senderId: message.sender_Id!)
                }
            }
        }
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.isUserInteractionEnabled = true
        if cell.textView != nil {
            cell.textView.textColor = UIColor.white
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.actionOnBubbleSelected(gesture:)))
        cell.addGestureRecognizer(tap)
        cell.tag = indexPath.row
        
        if message.message_type == MEDIA_TYPE_IMAGE {
            if message.media_Msg_Data == UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder")) {
                if !FileUtils.IsImageFileExists(fileName: message.media_url!) {
                    SDWebImageManager.shared().downloadImage(with: NSURL(string: message.media_url!) as URL!, options: [.continueInBackground, .lowPriority], progress: { (min, max) in
                        print("downloading progress \(min) and \(max)")
                    }, completed: { (image, error, type, finished, url) in
                        if image != nil {
                            message.media_Data = JSQPhotoMediaItem(image: Utils.rotateImage(image: image!))
                            message.media_Msg_Data = UIImagePNGRepresentation(image!)
                            message.videoLocalUrl = url?.absoluteString
                            self.messageDA.addUpdateMessages(message: message)
                            FileUtils.saveImageAtFileName(image: image!, fileName: (url?.absoluteString)!)
                        } else {
                            print("Image Download error found: \(error)")
                        }
                    })
                } else {
                    message.media_Data = JSQPhotoMediaItem(image: Utils.rotateImage(image: FileUtils.getImage(fileName: message.media_url!)!))
                    message.media_Msg_Data = UIImagePNGRepresentation(FileUtils.getImage(fileName: message.media_url!)!)
                    message.videoLocalUrl = message.media_url!
                    self.messageDA.addUpdateMessages(message: message)
                }
            }
        } else if message.message_type == MEDIA_TYPE_VIDEO {
            if message.videoLocalUrl == nil {
                cell.mediaView = message.media_Data?.mediaPlaceholderView()
                DispatchQueue.global(qos: .userInitiated).async {
                    print("downloadVideo");
                    let url = NSURL(string: message.media_url!);
                    let urlData = NSData(contentsOf: url! as URL);
                    if((urlData) != nil) {
                        let fileUrl = Utils.storeFileToLocal(fileData: urlData as! Data, fileName: message.sent_time!, fileEx: ".mov")
                        message.videoLocalUrl = fileUrl != nil ? "file://\(fileUrl!)" : nil
                        self.messageDA.addUpdateMessages(message: message)
                    }
                }
            } else {
                cell.mediaView = message.media_Data?.mediaView()
            }
        } else if message.message_type == MEDIA_TYPE_AUDIO {
            if message.videoLocalUrl == nil {
                DispatchQueue.global(qos: .userInitiated).async {
                    print("download Audio");
                    let url = NSURL(string: message.media_url!);
                    let urlData = NSData(contentsOf: url! as URL);
                    if((urlData) != nil) {
                        let fileUrl = Utils.storeFileToLocal(fileData: urlData as! Data, fileName: message.sent_time!, fileEx: ".m4a")
                        let url = URL(string: "file://\(fileUrl!)")!
                        let audioData = NSData(contentsOf:  url)
                        let audioItem = self.buildAudioItem(urlString: fileUrl!)
                        audioItem.audioViewAttributes.audioCategory = AVAudioSessionCategorySoloAmbient
                        
                        message.media_Data = audioItem
                        message.media_Msg_Data = audioData as Data?
                        message.videoLocalUrl = fileUrl != nil ? "file://\(fileUrl!)" : nil
                        self.messageDA.addUpdateMessages(message: message)
                    }
                }
            }
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.remove(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        if Utils.getCurrentUser().emailID! == data.sender_Id! {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let data = messages[indexPath.row]
        if Utils.getCurrentUser().emailID! == data.sender_Id {
            if data.message_status! == MESSAGE_STATUS_NOT_SENT && Utils.IsCurrentUserIsPatient() {
                return NSAttributedString(string: "\(MESSAGE_STATUS_NOT_DELIVERED)       \t")
            } else {
                return NSAttributedString(string: "\(data.message_status!)       \t")
            }
            
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 13.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        if indexPath.row != 0 {
            let preMessage = messages[indexPath.row - 1]
            if Utils.convertDateStringForDateString(dateString: message.sent_time!) != Utils.convertDateStringForDateString(dateString: preMessage.sent_time!) {
                return NSAttributedString(string: Utils.convertDateStringForDateString(dateString: message.sent_time!))
            } else {
                return nil
            }
        } else {
            return NSAttributedString(string: Utils.convertDateStringForDateString(dateString: message.sent_time!))
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = messages[indexPath.row]
        if indexPath.row != 0 {
            let preMessage = messages[indexPath.row - 1]
            if Utils.convertDateStringForDateString(dateString: message.sent_time!) != Utils.convertDateStringForDateString(dateString: preMessage.sent_time!) {
                return 13.0
            } else {
                return 0.0
            }
        } else {
            return 13.0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let data = messages[indexPath.row]
        if Utils.getCurrentUser().emailID! == data.sender_Id {
            if let image = Utils.user.image {
                return JSQMessagesAvatarImageFactory.avatarImage(with: Utils.cropToBounds(image: image), diameter: 40)
            } else {
                self.downloadProfilePic()
                return JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "profilePlaceholder"), diameter: 40)
            }
        } else {
            return JSQMessagesAvatarImageFactory.avatarImage(with: Utils.cropToBounds(image: receiverImage), diameter: 40)
        }
    }
    
    func actionOnBubbleSelected(gesture: UITapGestureRecognizer) {
        let message = self.messages[(gesture.view?.tag)!]
        if message.message_type == MEDIA_TYPE_IMAGE {
            self.selectedIndex = (gesture.view?.tag)!
            let galleryViewController = GalleryViewController(startIndex: 0, itemsDatasource: self, displacedViewsDatasource: self, configuration: galleryConfiguration())
            self.presentImageGallery(galleryViewController)
            
        } else if message.message_type == MEDIA_TYPE_VIDEO {
            if let videoLocalUrl = message.videoLocalUrl {
                let videoURL = NSURL(string: videoLocalUrl)
                let player = AVPlayer(url: videoURL! as URL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
    }
    
    //MARK:- ImageViewer
    func itemCount() -> Int {
        return 1
    }
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return UIImageView()
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let message = self.messages[self.selectedIndex!]
        let image1 = UIImage(data: message.media_Msg_Data!, scale: 1.0)
        return GalleryItem.image { $0(image1) }
    }
    
    func galleryConfiguration() -> GalleryConfiguration {
        return [
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.thumbnailsButtonMode(.none),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            
            GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
            GalleryConfigurationItem.overlayColorOpacity(1),
            GalleryConfigurationItem.overlayBlurOpacity(1),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffectStyle.light),
            
            GalleryConfigurationItem.maximumZoolScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),
            
            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
            
            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),
            
            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),
            
            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),
            
            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),
            
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50)
        ]
    }
    
    func refresh(sender: Timer) {
        self.getChatMessages(isShowHud: false)
    }
    
    @IBAction func actionOnRefresh(_ sender: UIBarButtonItem) {
        self.getChatMessages(isShowHud: true)
    }
    
    func getChatMessages(isShowHud: Bool) {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            if !self.isProgress {
                self.isProgress = true
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                if isShowHud {
                    self.inputToolbar.contentView!.textView!.resignFirstResponder()
                    Utils.showHUD(view: self.view)
                }
                
                DocTextApi.getChatMessages(roomId: (conversation?.chatRoomId!)!, limit: String(50), evaluatedKeyDict: nil, completionHandler: { (response, error) in
                    DispatchQueue.main.async {
                        if isShowHud {
                            Utils.hideHUD(view: self.view)
                        }
                        
                        self.isProgress = false
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        if (error != nil) {
                            print("Error occurred: \(error!.localizedDescription)")
                        } else {
                            
                            if let items = response?["Items"] as? [Dictionary<String, AnyObject>] {
                                
                                if let evaluatedKey = response?["LastEvaluatedKey"] as? Dictionary<String, AnyObject> {
                                    self.lastEvulatedKey.message_id = evaluatedKey["message_id"] as? String
                                    self.lastEvulatedKey.room_id = evaluatedKey["room_id"] as? String
                                    self.lastEvulatedKey.server_time = evaluatedKey["server_time"] as? String
                                }
                                
                                for item in items {
                                    print(item)
                                    
                                    let message_id = item["message_id"] as? String
                                    let message_type = item["message_type"] as? String
                                    let message_status = item["message_status"] as? String
                                    let text = item["message"] as? String
                                    let room_id = item["room_id"] as? String
                                    let sender_id = item["sender_id"] as? String
                                    let receiver_id = item["receiver_Id"] as? String
                                    let mediaUrl = item["media_url"] as? String
                                    let sent_time = item["sent_time"] as? String
                                    let transactionId = "nil"
                                    
                                    var message: Message? = nil
                                    if message_type == MEDIA_TYPE_TEXT {
                                        message = Message(messageId: message_id,
                                                          message: text,
                                                          messageType: message_type,
                                                          senderId: sender_id,
                                                          roomId: room_id,
                                                          sendTimeString: sent_time,
                                                          sendTimeobject: nil,
                                                          receiverId: receiver_id!,
                                                          message_status: message_status!,
                                                          paymentStatus: "Paid",
                                                          transactionId: transactionId
                                        )
                                    } else if message_type == MEDIA_TYPE_IMAGE {
                                        let oldMessage = self.messageDA.fetchMessageWith(sentTime: sent_time!)
                                        if oldMessage != nil {
                                            message = Message(messageId: message_id,
                                                              message: text,
                                                              messageType: message_type,
                                                              senderId: sender_id,
                                                              roomId:  room_id,
                                                              sendTimeString: sent_time,
                                                              sendTimeobject: nil,
                                                              media: oldMessage!.media_Data,
                                                              media_Msg_Data: oldMessage!.media_Msg_Data,
                                                              mediaUrl: mediaUrl,
                                                              receiverId: receiver_id!,
                                                              message_status: message_status!,
                                                              thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                              videoLocalUrl: nil,
                                                              paymentStatus: "Paid",
                                                              transactionId: transactionId)
                                            
                                        } else {
                                            message = Message(messageId: message_id,
                                                              message: text,
                                                              messageType: message_type,
                                                              senderId: sender_id,
                                                              roomId:  room_id,
                                                              sendTimeString: sent_time,
                                                              sendTimeobject: nil,
                                                              media: JSQPhotoMediaItem(image: #imageLiteral(resourceName: "placeholder")),
                                                              media_Msg_Data: UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder")),
                                                              mediaUrl: mediaUrl,
                                                              receiverId: receiver_id!,
                                                              message_status: message_status!,
                                                              thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                              videoLocalUrl: nil,
                                                              paymentStatus: "Paid",
                                                              transactionId: transactionId)
                                            
                                        }
                                    } else if message_type == MEDIA_TYPE_VIDEO  {
                                        let oldMessage = self.messageDA.fetchMessageWith(sentTime: sent_time!)
                                        if oldMessage != nil {
                                            
                                            message = Message(messageId: message_id,
                                                              message: text,
                                                              messageType: message_type,
                                                              senderId: sender_id,
                                                              roomId:  room_id,
                                                              sendTimeString: sent_time,
                                                              sendTimeobject: nil,
                                                              media: oldMessage!.media_Data,
                                                              media_Msg_Data: oldMessage!.media_Msg_Data,
                                                              mediaUrl: mediaUrl,
                                                              receiverId: receiver_id!,
                                                              message_status: message_status!,
                                                              thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                              videoLocalUrl: oldMessage!.videoLocalUrl,
                                                              paymentStatus: "Paid",
                                                              transactionId: transactionId)
                                            
                                            if FileUtils.IsVideoFileExists(fileName: message?.sent_time!) {
                                                message?.videoLocalUrl = "file://\(FileUtils.getVideoFilePath(fileName: (message?.sent_time!)!)!)"
                                            } else {
                                                message?.videoLocalUrl = nil
                                            }
                                            
                                        } else {
                                            message = Message(messageId: message_id,
                                                              message: text,
                                                              messageType: message_type,
                                                              senderId: sender_id,
                                                              roomId:  room_id,
                                                              sendTimeString: sent_time,
                                                              sendTimeobject: nil,
                                                              media: JSQPhotoMediaItem(image: #imageLiteral(resourceName: "placeholder")),
                                                              media_Msg_Data: UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder")),
                                                              mediaUrl: mediaUrl,
                                                              receiverId: receiver_id!,
                                                              message_status: message_status!,
                                                              thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                              videoLocalUrl: nil,
                                                              paymentStatus: "Paid",
                                                              transactionId: transactionId)
                                            
                                        }
                                    } else if message_type == MEDIA_TYPE_AUDIO  {
                                        let oldMessage = self.messageDA.fetchMessageWith(sentTime: sent_time!)
                                        if oldMessage != nil {
                                            message = Message(messageId: message_id,
                                                              message: text,
                                                              messageType: message_type,
                                                              senderId: sender_id,
                                                              roomId:  room_id,
                                                              sendTimeString: sent_time,
                                                              sendTimeobject: nil,
                                                              media: oldMessage!.media_Data,
                                                              media_Msg_Data: oldMessage!.media_Msg_Data,
                                                              mediaUrl: mediaUrl,
                                                              receiverId: receiver_id!,
                                                              message_status: message_status!,
                                                              thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                              videoLocalUrl: oldMessage!.videoLocalUrl,
                                                              paymentStatus: "Paid",
                                                              transactionId: transactionId)
                                            
                                            if FileUtils.IsAudioFileExists(fileName: message?.sent_time!) {
                                                message?.videoLocalUrl = "file://\(FileUtils.getAudioFilePath(fileName: (message?.sent_time!)!)!)"
                                            } else {
                                                message?.videoLocalUrl = nil
                                            }
                                            
                                            
                                        } else {
                                            message = Message(messageId: message_id,
                                                              message: text,
                                                              messageType: message_type,
                                                              senderId: sender_id,
                                                              roomId:  room_id,
                                                              sendTimeString: sent_time,
                                                              sendTimeobject: nil,
                                                              media: nil,
                                                              media_Msg_Data: nil,
                                                              mediaUrl: mediaUrl,
                                                              receiverId: receiver_id!,
                                                              message_status: message_status!,
                                                              thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                              videoLocalUrl: nil,
                                                              paymentStatus: "Paid",
                                                              transactionId: transactionId)
                                            
                                        }
                                    }
                                    self.messageDA.addUpdateMessages(message: message!)
                                    for msg in self.messages {
                                        if msg.sent_time == message!.sent_time! {
                                            msg.message_status = message!.message_status!
                                        }
                                    }
                                }
                                
                                
                                
                                let unreadObjects = self.getUnreadMessageIDs()
                                if unreadObjects.0.count != 0 {
                                    self.resetOffset()
                                    self.fetchMessageFromDB()
                                    self.checkMessageStatus()
                                    self.scrollToBottom(animated: false)
                                    self.updateMessageStatus(messageIds: unreadObjects.0)
                                } else {
                                    self.collectionView.reloadData()
                                }
                                
                                
                                
                                
                            }
                        }
                    }
                    
                })
            }
        } else {
            print("Internet is not connected. Calling from Chat View controller...")
        }
    }
    
    
    func fetchMessageFromDB() {
        let fetchedMsgs = messageDA.fetchMessageList(roomId: (conversation?.chatRoomId)!, offset: messageOffset)
        self.messages = fetchedMsgs + self.messages
        self.checkMessageOffset()
        self.collectionView.reloadData()
    }
    
    func AWSS3Configuration() {
        
        let CognitoPoolID = COGNITO_IDENTITY_POOL_ID
        let Region = AWSRegionType.usWest2
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,
                                                                identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func checkCameraPermission(type: String) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
            self.showImagePickerForCaptureImageVideo(type: type)
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true {
                    self.showImagePickerForCaptureImageVideo(type: type)
                } else {
                    let alertController = UIAlertController(title: "Camera Access Denied!", message: "Unable to access camera. Please enable camera access in Settings.", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                        print("you have pressed the Cancel button");
                    }
                    alertController.addAction(cancelAction)
                    
                    let OKAction = UIAlertAction(title: "Go to Settings", style: .default) { (action:UIAlertAction!) in
                        Utils.openAppInSettings()
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion:nil)
                }
            });
        }
    }
    
    func showImagePickerForCaptureImageVideo(type: String) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            self.imagePicker.mediaTypes = [type]
            self.present(self.imagePicker, animated: true, completion: nil)
        } else {
            Utils.showAlert(title: "", message: "You don't have camera", viewController: self)
        }
    }
    
    func showImagePickerForChooseExisting() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            self.imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        if mediaType == kUTTypeImage {
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let image = originalImage.resizeWith(percentage: 0.5)
                if let data = UIImagePNGRepresentation(Utils.rotateImage(image: image!)) {
                    let fileurl = self.getDocumentsDirectory().appendingPathComponent("\(ProcessInfo.processInfo.globallyUniqueString).png")
                    try? data.write(to: fileurl)
                    let photoItem = JSQPhotoMediaItem(image: Utils.rotateImage(image: image!))
                    self.addMedia(photoItem!, mediaData: data, mediaType: MEDIA_TYPE_IMAGE, mediaURL: fileurl, thumnailImage: nil)
                }
            } else{
                print("Something went wrong")
            }
        } else {
            if let videoURL = info["UIImagePickerControllerMediaURL"] as? NSURL {
                let videoData = NSData(contentsOf: videoURL as URL)
                let thumbnailImage = Utils.thumbnailForVideoAtURL(url: videoURL as URL)
                let videoItem = self.buildVideoItem(videoUrl: videoURL as URL)
                self.addMedia(videoItem, mediaData: videoData as! Data, mediaType: MEDIA_TYPE_VIDEO, mediaURL: videoURL as URL, thumnailImage: thumbnailImage)
            } else{
                print("Something went wrong")
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        let selectedSongs = mediaItemCollection.items
        if selectedSongs.count > 0 {
            let song = selectedSongs[0]
            if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL {
                print(AVAsset(url:url as URL))
                dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Asset Loaded", message: "Audio Loaded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
                present(alert, animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Asset Not Available", message: "Audio Not Loaded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
                present(alert, animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        print("cancel media picker...")
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func isOutgoingMsg(senderId: String) -> Bool {
        if Utils.getCurrentUser().emailID! == senderId {
            return true
        } else {
            return false
        }
    }
    
    func downloadVideo(videoImageUrl:String) {
        DispatchQueue.global(qos: .userInitiated).async {
            print("downloadVideo");
            let url = NSURL(string: videoImageUrl);
            let urlData = NSData(contentsOf: url! as URL);
            if((urlData) != nil) {
                
            }
        }
    }
    
    //MARK:- IQAudioRecorderViewControllerDelegate Methods
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            audioFilePath = filePath
            let url = URL(fileURLWithPath: filePath)
            let audioData = NSData(contentsOf:  url)
            let audioItem = self.buildAudioItem(urlString: filePath)
            audioItem.audioViewAttributes.audioCategory = AVAudioSessionCategorySoloAmbient
            self.addMedia(audioItem, mediaData: audioData as! Data, mediaType: MEDIA_TYPE_AUDIO, mediaURL: url, thumnailImage: nil)
            controller.dismiss(animated: true, completion: nil)
        } else {
            controller.showAlertForInternetNotConnected()
        }
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func recordAudioAction() {
        
        let controller = IQAudioRecorderViewController()
        controller.delegate = self
        controller.title = "Record Audio"
        controller.maximumRecordDuration = 300
        controller.allowCropping = false
        controller.barStyle = .default;
        self.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
    
    
    // calling when getting response from sending messages..
    func actionOnRefreshChat(_ notification: NSNotification) {
        if let sentMsg = notification.userInfo?["sentMessage"] as? Message {
            for message in self.messages {
                if message.sent_time! == sentMsg.sent_time! {
                    message.message_id = sentMsg.message_id
                    message.message_status = sentMsg.message_status
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    // Download Image with Progress
    func downloadProfilePic() {
        if let picUrl = Utils.user.profilePicUrl {
            SDWebImageManager.shared().downloadImage(with: NSURL(string: picUrl) as URL!, options: [.continueInBackground, .lowPriority], progress: { (min, max) in
                print("downloading progress \(min) and \(max)")
            }, completed: { (image, error, type, finished, url) in
                if image != nil {
                    Utils.user.image = image
                } else {
                    print("Image Download error found: \(error)")
                }
            })
        }
    }
    
    //MARK: makepaymentdelegate
    func refreshChatScreen() {
    }
    
    //MARK: - Update message status
    func updateMessageStatus(messageIds: [String]) {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            DocTextApi.updateMessageStatus(messageIds: messageIds, roomId: (conversation?.chatRoomId!)!, messageStatus: Utils.IsCurrentUserIsPatient() ? MESSAGE_STATUS_READ : MESSAGE_STATUS_DELIVERED) { (result, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                    } else {
                        let status = result?["success"] as? Int
                        if status != nil && status == 1 {
                            print("Message status updated successfully....")
                        } else {
                            print("Error found in update message status: \(error?.localizedDescription)")
                        }
                    }
                }
            }
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
        
    }
    
    func checkMessageStatus() {
        var unreadMsgIds = [String]()
        for message in self.messages {
            if Utils.getCurrentUser().emailID! == message.receiver_Id! {
                if message.message_status == (!Utils.IsCurrentUserIsPatient() ? "Not delivered" : "Sent") {
                    unreadMsgIds.append(message.message_id!)
                }
            }
        }
        
        if unreadMsgIds.count != 0 {
            self.updateMessageStatus(messageIds: unreadMsgIds)
        }
    }
    
    func getUnreadMessageIDs() -> ([String],[Message]) {
        
        let unreadObjects = messageDA.fetchUnReadMessageList()
        return (unreadObjects.1, unreadObjects.0)
    }
    
    func checkInternetConnection() {
        if Utils.reachability.currentReachabilityStatus == .notReachable {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    func checkMessageOffset() {
        if (self.messages.count == 0) || (self.messages.count % 30 != 0) {
            self.isMaxMsgLimitAchieved = true
        }
    }
    
        override func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView.contentOffset.y < 100 && !self.isMaxMsgLimitAchieved {
                self.messageOffset += 30
                fetchMessageFromDB()
                self.scroll(to: IndexPath(row: 30, section: 0), animated: false)
            }
        }
    
    
    func getAllChatMessagesFromServer() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.inputToolbar.contentView!.textView!.resignFirstResponder()
            Utils.showHUD(view: self.view)
            
            let param: Dictionary<String, Any>?
            if let msgId = self.lastEvulatedKey.message_id {
                param = ["message_id": msgId,
                         "room_id": self.lastEvulatedKey.room_id!,
                         "server_time": self.lastEvulatedKey.server_time!]
            } else {
                param = nil
            }
            
            DocTextApi.getChatMessages(roomId: (conversation?.chatRoomId!)!,limit: String(30), evaluatedKeyDict: param, completionHandler: { (response, error) in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                    if (error != nil) {
                        print("Error occurred: \(error!.localizedDescription)")
                    } else {
                        
                        if let items = response?["Items"] as? [Dictionary<String, AnyObject>] {
                            
                            if let evaluatedKey = response?["LastEvaluatedKey"] as? Dictionary<String, AnyObject> {
                                self.lastEvulatedKey.message_id = evaluatedKey["message_id"] as? String
                                self.lastEvulatedKey.room_id = evaluatedKey["room_id"] as? String
                                self.lastEvulatedKey.server_time = evaluatedKey["server_time"] as? String
                            }
                            
                            for item in items {
                                print(item)
                                
                                let message_id = item["message_id"] as? String
                                let message_type = item["message_type"] as? String
                                let message_status = item["message_status"] as? String
                                let text = item["message"] as? String
                                let room_id = item["room_id"] as? String
                                let sender_id = item["sender_id"] as? String
                                let receiver_id = item["receiver_Id"] as? String
                                let mediaUrl = item["media_url"] as? String
                                let sent_time = item["sent_time"] as? String
                                let transactionId = "nil"
                                
                                var message: Message? = nil
                                if message_type == MEDIA_TYPE_TEXT {
                                    message = Message(messageId: message_id,
                                                      message: text,
                                                      messageType: message_type,
                                                      senderId: sender_id,
                                                      roomId: room_id,
                                                      sendTimeString: sent_time,
                                                      sendTimeobject: nil,
                                                      receiverId: receiver_id!,
                                                      message_status: message_status!,
                                                      paymentStatus: "Paid",
                                                      transactionId: transactionId)
                                } else if message_type == MEDIA_TYPE_IMAGE {
                                    let oldMessage = self.messageDA.fetchMessageWith(sentTime: sent_time!)
                                    if oldMessage != nil {
                                        message = Message(messageId: message_id,
                                                          message: text,
                                                          messageType: message_type,
                                                          senderId: sender_id,
                                                          roomId:  room_id,
                                                          sendTimeString: sent_time,
                                                          sendTimeobject: nil,
                                                          media: oldMessage!.media_Data,
                                                          media_Msg_Data: oldMessage!.media_Msg_Data,
                                                          mediaUrl: mediaUrl,
                                                          receiverId: receiver_id!,
                                                          message_status: message_status!,
                                                          thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                          videoLocalUrl: nil,
                                                          paymentStatus: "Paid",
                                                          transactionId: transactionId)
                                        
                                    } else {
                                        message = Message(messageId: message_id,
                                                          message: text,
                                                          messageType: message_type,
                                                          senderId: sender_id,
                                                          roomId:  room_id,
                                                          sendTimeString: sent_time,
                                                          sendTimeobject: nil,
                                                          media: JSQPhotoMediaItem(image: #imageLiteral(resourceName: "placeholder")),
                                                          media_Msg_Data: UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder")),
                                                          mediaUrl: mediaUrl,
                                                          receiverId: receiver_id!,
                                                          message_status: message_status!,
                                                          thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                          videoLocalUrl: nil,
                                                          paymentStatus: "Paid",
                                                          transactionId: transactionId)
                                        
                                    }
                                } else if message_type == MEDIA_TYPE_VIDEO  {
                                    let oldMessage = self.messageDA.fetchMessageWith(sentTime: sent_time!)
                                    if oldMessage != nil {
                                        
                                        message = Message(messageId: message_id,
                                                          message: text,
                                                          messageType: message_type,
                                                          senderId: sender_id,
                                                          roomId:  room_id,
                                                          sendTimeString: sent_time,
                                                          sendTimeobject: nil,
                                                          media: oldMessage!.media_Data,
                                                          media_Msg_Data: oldMessage!.media_Msg_Data,
                                                          mediaUrl: mediaUrl,
                                                          receiverId: receiver_id!,
                                                          message_status: message_status!,
                                                          thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                          videoLocalUrl: oldMessage!.videoLocalUrl,
                                                          paymentStatus: "Paid",
                                                          transactionId: transactionId)
                                        
                                        if FileUtils.IsVideoFileExists(fileName: message?.sent_time!) {
                                            message?.videoLocalUrl = "file://\(FileUtils.getVideoFilePath(fileName: (message?.sent_time!)!)!)"
                                        } else {
                                            message?.videoLocalUrl = nil
                                        }
                                        
                                    } else {
                                        message = Message(messageId: message_id,
                                                          message: text,
                                                          messageType: message_type,
                                                          senderId: sender_id,
                                                          roomId:  room_id,
                                                          sendTimeString: sent_time,
                                                          sendTimeobject: nil,
                                                          media: JSQPhotoMediaItem(image: #imageLiteral(resourceName: "placeholder")),
                                                          media_Msg_Data: UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder")),
                                                          mediaUrl: mediaUrl,
                                                          receiverId: receiver_id!,
                                                          message_status: message_status!,
                                                          thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                          videoLocalUrl: nil,
                                                          paymentStatus: "Paid",
                                                          transactionId: transactionId)
                                        
                                    }
                                } else if message_type == MEDIA_TYPE_AUDIO  {
                                    let oldMessage = self.messageDA.fetchMessageWith(sentTime: sent_time!)
                                    if oldMessage != nil {
                                        message = Message(messageId: message_id,
                                                          message: text,
                                                          messageType: message_type,
                                                          senderId: sender_id,
                                                          roomId:  room_id,
                                                          sendTimeString: sent_time,
                                                          sendTimeobject: nil,
                                                          media: oldMessage!.media_Data,
                                                          media_Msg_Data: oldMessage!.media_Msg_Data,
                                                          mediaUrl: mediaUrl,
                                                          receiverId: receiver_id!,
                                                          message_status: message_status!,
                                                          thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                          videoLocalUrl: oldMessage!.videoLocalUrl,
                                                          paymentStatus: "Paid",
                                                          transactionId: transactionId)
                                        
                                        if FileUtils.IsAudioFileExists(fileName: message?.sent_time!) {
                                            message?.videoLocalUrl = "file://\(FileUtils.getAudioFilePath(fileName: (message?.sent_time!)!)!)"
                                        } else {
                                            message?.videoLocalUrl = nil
                                        }
                                        
                                        
                                    } else {
                                        message = Message(messageId: message_id,
                                                          message: text,
                                                          messageType: message_type,
                                                          senderId: sender_id,
                                                          roomId:  room_id,
                                                          sendTimeString: sent_time,
                                                          sendTimeobject: nil,
                                                          media: nil,
                                                          media_Msg_Data: nil,
                                                          mediaUrl: mediaUrl,
                                                          receiverId: receiver_id!,
                                                          message_status: message_status!,
                                                          thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                                          videoLocalUrl: nil,
                                                          paymentStatus: "Paid",
                                                          transactionId: transactionId)
                                        
                                    }
                                }
                                
                                self.messageDA.addUpdateMessages(message: message!)
                                
                            }
                            
                            let unreadObjects = self.getUnreadMessageIDs()
                            if unreadObjects.0.count != 0 {
                                self.updateMessageStatus(messageIds: unreadObjects.0)
                            }
                            
                            if (self.messageLimit - self.messageDA.getMessagesCount(roomId: (self.conversation?.chatRoomId)!)) >= 30 {
                                self.resetOffset()
                                self.fetchMessageFromDB()
                            } else {
                                self.messageLimit += 30
                                self.getAllChatMessagesFromServer()
                            }
                        }
                    }
                }
                
            })
        } else {
            print("Internet is not connected. Calling from Chat View controller...")
        }
    }
    
    func resetOffset() {
        self.messageOffset = 0
        self.isMaxMsgLimitAchieved = false
        self.messages.removeAll()
    }
 }
 
 
 extension UIImageView: DisplaceableView {}
 
 extension UIImage {
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
 }
 
