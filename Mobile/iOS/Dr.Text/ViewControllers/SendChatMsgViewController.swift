//
//  SendChatMsgViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 13/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import SDWebImage

protocol makePaymentDelegate {
    func refreshChatScreen()
}

class SendChatMsgViewController: UIViewController {
    
    @IBOutlet weak var sendItemForLbl: UILabel!
    @IBOutlet weak var creditCardNormalView: UIView!
    @IBOutlet weak var creditCardNormalViewLbl: UILabel!
    @IBOutlet weak var senderImgOutterView: UIView!
    @IBOutlet weak var senderImgView: UIImageView!
    @IBOutlet weak var receiverImgOutterView: UIView!
    @IBOutlet weak var receiverImgView: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var paymentTypeView: UIView!
    @IBOutlet weak var paymentBtn: UIButton!
    @IBOutlet weak var sendTextBtn: UIButton!
    @IBOutlet var mainViewTCons: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var creditCardIssueView: UIView!
    @IBOutlet weak var creditCardNoLbl: UILabel!
    @IBOutlet weak var creditCardIssueRedView: UIImageView!
    @IBOutlet weak var redLblText: UILabel!
    var conversation: Conversation!
    var delegate: makePaymentDelegate!
    var currentMessage: Message!
    let messageDA = MessageDA()
    var amount = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setButtonText()
        senderImgOutterView.layer.masksToBounds = true
        senderImgOutterView.layer.cornerRadius = senderImgOutterView.frame.size.height / 2
        senderImgView.layer.masksToBounds = true
        senderImgView.layer.cornerRadius = senderImgView.frame.size.height / 2
        
        receiverImgOutterView.layer.masksToBounds = true
        receiverImgOutterView.layer.cornerRadius = receiverImgOutterView.frame.size.height / 2
        receiverImgView.layer.masksToBounds = true
        receiverImgView.layer.cornerRadius = receiverImgView.frame.size.height / 2
        self.disableNextBtn(button: sendTextBtn)
        
        downloadReceiverProfilePic(url: conversation.convImageUrl)
        downloadSenderProfilePic(url: Utils.user.profilePicUrl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        choosePaymentView()
        getUserDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mainViewTCons.constant = (paymentTypeView.frame.origin.y - mainView.frame.size.height) / 2
    }
    
    func setBackButton() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackChevron") , style: .plain, target: self, action: #selector(BaseViewController.actionOnBackBtn(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    
    func actionOnBackBtn(sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
    
    func choosePaymentView()  {
        if !Utils.user.iSCardWorking {
            paymentTypeView.isHidden = false
            creditCardIssueView.isHidden = true
            creditCardNormalView.isHidden = true
            self.disableNextBtn(button: sendTextBtn)
        } else {
            if Utils.user.cardId! != "nil" {
                paymentTypeView.isHidden = true
                creditCardIssueView.isHidden = true
                creditCardNormalView.isHidden = false
                creditCardNormalViewLbl.text! = "\(Utils.getAbbrivatedBrandName(brandName: Utils.user.cardBrand!)) xxxx xxxx xxxx \(Utils.user.cardLastFourDigit!)"
                creditCardNoLbl.text! = "\(Utils.getAbbrivatedBrandName(brandName: Utils.user.cardBrand!)) xxxx xxxx xxxx \(Utils.user.cardLastFourDigit!)"
                self.enableNextBtn(button: sendTextBtn)
            } else {
                paymentTypeView.isHidden = false
                creditCardIssueView.isHidden = true
                creditCardNormalView.isHidden = true
                self.disableNextBtn(button: sendTextBtn)
            }
        }
    }
    
    @IBAction func actionOnPaymentBtn(_ sender: UIButton) {
        let paymentVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "paymentViewController") as! paymentViewController
        self.navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    @IBAction func actionOnSendTextBtn(_ sender: UIButton) {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            
            if Int(self.amount) == 0 {
                self.currentMessage.payment_status = "Paid"
                 self.messageDA.addUpdateMessages(message: self.currentMessage)
                Utils.sendPendingMessagesToServer()
                
                if (self.delegate != nil) {
                    self.delegate.refreshChatScreen()
                }
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                if Utils.user.cardId! == "nil" {
                    Utils.showAlert(title: "", message: "You must setup a payment method", viewController: self)
                } else {
                    Utils.showHUD(view: self.view.window!)
                    DocTextApi.makePayment(customerId: Utils.user.customerId!, amount: self.amount, completionHandler: { (result, error) in
                        DispatchQueue.main.async {
                            Utils.hideHUD(view: self.view.window!)
                            if error != nil {
                                Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                            } else {
                                let status = result!["status"] as? String
                                let transactionId = result!["id"] as? String
                                if status != nil && status == "succeeded" {
                                    self.currentMessage.payment_status = "Paid"
                                    self.currentMessage.transactionId = transactionId
                                    self.messageDA.addUpdateMessages(message: self.currentMessage)
                                    Utils.sendPendingMessagesToServer()
                                    
                                    if (self.delegate != nil) {
                                        self.delegate.refreshChatScreen()
                                    }
                                    _ = self.navigationController?.popViewController(animated: true)
                                } else {
                                    self.paymentTypeView.isHidden = true
                                    self.creditCardIssueView.isHidden = false
                                    self.creditCardNormalView.isHidden = true
                                    self.disableNextBtn(button: self.sendTextBtn)
                                }
                            }
                        }
                    })
                }
            }
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    // Download Image with Progress
    func downloadReceiverProfilePic(url: String?) {
        if let picUrl = url {
            if !FileUtils.IsImageFileExists(fileName: picUrl) {
                SDWebImageManager.shared().downloadImage(with: NSURL(string: picUrl) as URL!, options: [.continueInBackground, .lowPriority], progress: { (min, max) in
                    print("downloading progress \(min) and \(max)")
                }, completed: { (image, error, type, finished, url) in
                    if image != nil {
                        self.receiverImgView.image = image
                        FileUtils.saveImageAtFileName(image: image!, fileName: (url?.absoluteString)!)
                    } else {
                        print("Image Download error found: \(error)")
                        self.receiverImgView.image = #imageLiteral(resourceName: "profilePlaceholder")
                    }
                })
            } else {
                self.receiverImgView.image = FileUtils.getImage(fileName: picUrl)
            }
            
        } else {
            self.receiverImgView.image = #imageLiteral(resourceName: "profilePlaceholder")
        }
    }
    
    func downloadSenderProfilePic(url: String?) {
        if let picUrl = url {
            if !FileUtils.IsImageFileExists(fileName: picUrl) {
                SDWebImageManager.shared().downloadImage(with: NSURL(string: picUrl) as URL!, options: [.continueInBackground, .lowPriority], progress: { (min, max) in
                    print("downloading progress \(min) and \(max)")
                }, completed: { (image, error, type, finished, url) in
                    if image != nil {
                        self.senderImgView.image = image
                        FileUtils.saveImageAtFileName(image: image!, fileName: (url?.absoluteString)!)
                    } else {
                        print("Image Download error found: \(error)")
                        self.senderImgView.image = #imageLiteral(resourceName: "profilePlaceholder")
                    }
                })
            } else {
                self.senderImgView.image = FileUtils.getImage(fileName: picUrl)
            }
            
        } else {
            self.senderImgView.image = #imageLiteral(resourceName: "profilePlaceholder")
        }
    }
    
    @IBAction func actionOnUpdateIt(_ sender: UIButton) {
        let paymentVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "paymentViewController") as! paymentViewController
        self.navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    func setButtonText() {
        if currentMessage.message_type! == MEDIA_TYPE_TEXT {
            self.sendTextBtn.setTitle("Send text", for: .normal)
            self.sendItemForLbl.text = "Send this text for"
        } else if currentMessage.message_type! == MEDIA_TYPE_IMAGE {
            self.sendTextBtn.setTitle("Send image", for: .normal)
            self.sendItemForLbl.text = "Send this image for"
        } else if currentMessage.message_type! == MEDIA_TYPE_AUDIO {
            self.sendTextBtn.setTitle("Send audio", for: .normal)
            self.sendItemForLbl.text = "Send this audio for"
        } else if currentMessage.message_type! == MEDIA_TYPE_VIDEO {
            self.sendTextBtn.setTitle("Send video", for: .normal)
            self.sendItemForLbl.text = "Send this video for"
        }
    }
    
    func getUserDetails() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            DocTextApi.getUserDetails(userId: conversation.doctorId!) { (result, error) in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if error != nil {
                        self.showAlertWithMessage(title: "Error Found", message: error!.localizedDescription)
                    } else {
                        
                        if let item = result?["Item"] as? Dictionary<String, Any> {
                            self.amount = (item["DoctorCharge"] as? String)!.replacingOccurrences(of: "$", with:"")
                            self.priceLbl.text = "$\(self.amount).00"
                            
                            if Int(self.amount) == 0 {
                                self.enableNextBtn(button: self.sendTextBtn)
                            }
                        }
                    }
                }
            }
        } else {
            self.showAlertWithMessage(title: "No Internet Connection", message: "Sorry, no Internet connectivity detected. Please reconnect and try again!")
        }
    }
    
    func showAlertWithMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func disableNextBtn(button: UIButton) {
        button.backgroundColor = #colorLiteral(red: 0.8078431373, green: 0.9137254902, blue: 0.9529411765, alpha: 1)
        button.setTitleColor( #colorLiteral(red: 0.04705882353, green: 0.6941176471, blue: 0.9490196078, alpha: 0.5) , for: .normal)
    }
    
    func enableNextBtn(button: UIButton) {
        button.backgroundColor = #colorLiteral(red: 0.04705882353, green: 0.6980392157, blue: 0.9529411765, alpha: 1)
        button.setTitleColor( #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) , for: .normal)
    }
}
