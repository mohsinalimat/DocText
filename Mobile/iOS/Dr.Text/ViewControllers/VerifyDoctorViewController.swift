//
//  VerifyDoctorViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 14/11/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class VerifyDoctorViewController: BaseViewController, baseViewControllerProtocolDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var fristDigitLbl: UILabel!
    @IBOutlet weak var secondDigitLbl: UILabel!
    @IBOutlet weak var thirdDigitLbl: UILabel!
    @IBOutlet weak var fourthDigitLbl: UILabel!
    @IBOutlet weak var fifthDigitLbl: UILabel!
    @IBOutlet weak var sixthDigitLbl: UILabel!
    @IBOutlet weak var dummyTextField: dumTextField!
    var dashboardelegate: dashboardProtocolDelegate?
    var doctorPatientListdelegate: DoctorPatientListProtocolDelegate?
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        dummyTextField.becomeFirstResponder()
        dummyTextField.addTarget(self, action: #selector(textChangedAction), for: .editingChanged)
        errorView.isHidden = true
        
        setEmptyLblProperty(label: fristDigitLbl)
        setEmptyLblProperty(label: secondDigitLbl)
        setEmptyLblProperty(label: thirdDigitLbl)
        setEmptyLblProperty(label: fourthDigitLbl)
        setEmptyLblProperty(label: fifthDigitLbl)
        setEmptyLblProperty(label: sixthDigitLbl)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }
    
    // MARK:- UITextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count > 0 && !Scanner(string: string).scanInt(nil) {
            return false
        }
        
        let oldLength = textField.text?.characters.count
        let replacementLength = string.characters.count
        let rangeLength = range.length
        
        let newLength = oldLength! -  rangeLength + replacementLength
        
        if newLength > 6 {
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.offSetForKeyboard = 60.0
        self.activeField = textField
    }
    
    func textChangedAction() {
        let text = dummyTextField.text!
        errorView.isHidden = true
        if text.characters.count == 0 {
            setEmptyLblProperty(label: fristDigitLbl)
            setEmptyLblProperty(label: secondDigitLbl)
            setEmptyLblProperty(label: thirdDigitLbl)
            setEmptyLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 1 {
            fristDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setEmptyLblProperty(label: secondDigitLbl)
            setEmptyLblProperty(label: thirdDigitLbl)
            setEmptyLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 2 {
            secondDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setEmptyLblProperty(label: thirdDigitLbl)
            setEmptyLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 3 {
            thirdDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setFilledLblProperty(label: thirdDigitLbl)
            setEmptyLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 4 {
            fourthDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setFilledLblProperty(label: thirdDigitLbl)
            setFilledLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 5 {
            fifthDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setFilledLblProperty(label: thirdDigitLbl)
            setFilledLblProperty(label: fourthDigitLbl)
            setFilledLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 6 {
            sixthDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setFilledLblProperty(label: thirdDigitLbl)
            setFilledLblProperty(label: fourthDigitLbl)
            setFilledLblProperty(label: fifthDigitLbl)
            setFilledLblProperty(label: sixthDigitLbl)
            self.verifyDoctor()
        }
    }
    
    
    func setEmptyLblProperty(label: UILabel) {
        label.text = ""
        label.layer.masksToBounds = true
        label.layer.borderColor = #colorLiteral(red: 0.1607843137, green: 0.1607843137, blue: 0.1607843137, alpha: 1).cgColor
        label.layer.borderWidth = 0.8
        label.layer.cornerRadius = 4.0
    }
    
    func setFilledLblProperty(label: UILabel) {
        label.layer.masksToBounds = true
        label.layer.borderColor = #colorLiteral(red: 0.4980392157, green: 0.9882352941, blue: 0.662745098, alpha: 1).cgColor
        label.layer.borderWidth = 0.8
        label.layer.cornerRadius = 4.0
    }
    
    func setErrorLblProperty(label: UILabel) {
        label.layer.masksToBounds = true
        label.layer.borderColor = #colorLiteral(red: 0.9960784314, green: 0.2196078431, blue: 0.1411764706, alpha: 1).cgColor
        label.layer.borderWidth = 0.8
        label.layer.cornerRadius = 4.0
    }
    
    func showErrorView() {
        errorView.isHidden = false
        setErrorLblProperty(label: fristDigitLbl)
        setErrorLblProperty(label: secondDigitLbl)
        setErrorLblProperty(label: thirdDigitLbl)
        setErrorLblProperty(label: fourthDigitLbl)
        setErrorLblProperty(label: fifthDigitLbl)
        setErrorLblProperty(label: sixthDigitLbl)
    }
    
    func hideErrorView() {
        errorView.isHidden = true
        dummyTextField.text = ""
        setEmptyLblProperty(label: fristDigitLbl)
        setEmptyLblProperty(label: secondDigitLbl)
        setEmptyLblProperty(label: thirdDigitLbl)
        setEmptyLblProperty(label: fourthDigitLbl)
        setEmptyLblProperty(label: fifthDigitLbl)
        setEmptyLblProperty(label: sixthDigitLbl)
    }
    
    
    @IBAction func actionOnTryAgain(_ sender: UIButton) {
        hideErrorView()
    }
    
    func doctorAddPermission(user: User) {
        let alertController = UIAlertController(title: "Confirm Doctor", message: "Dr. \(user.firstName!) \(user.lastName!), \(user.doctorType!), will be added to your list of Doctors", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            DispatchQueue.main.async {
                self.createRoom(user: user)
            }
        }
        alertController.addAction(OKAction)
        dummyTextField.resignFirstResponder()
        self.present(alertController, animated: true, completion:nil)
    }
    
    func createRoom(user: User) {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            dummyTextField.resignFirstResponder()
            
            DocTextApi.createRoom(docId: user.emailID!, docFirstName: user.firstName!, docLastName: user.lastName!, docProfilePic: user.profilePicUrl == nil ? "nil" : user.profilePicUrl!, completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if error != nil {
                        self.dummyTextField.becomeFirstResponder()
                        Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                    } else {
                        let status = result?["success"] as? Int
                        if status != nil && status == 1 {
                            self.getRooms()
                        } else {
                            self.dummyTextField.becomeFirstResponder()
                            Utils.showAlert(title: "Error Found", message: "Something went wrong!", viewController: self)
                        }
                    }
                }
            })
        } else {
            self.dummyTextField.becomeFirstResponder()
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    func verifyDoctor() {
        
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            dummyTextField.resignFirstResponder()
            print( Utils.getCurrentUser().phoneNumber!)
            print(dummyTextField.text!)
            print(Utils.getCurrentUser().emailID!)
            
            var phoneNo = String()
            if Utils.getCurrentUser().phoneNumber!.characters.count > 10 {
                phoneNo =  Utils.getCurrentUser().phoneNumber!
            } else {
                phoneNo = "\(Utils.getPhoneNoCountryCode())\(Utils.getCurrentUser().phoneNumber!)"
            }
            
            DocTextApi.verifyDoctor(phoneNo: phoneNo, patientId: Utils.getCurrentUser().emailID!, code: dummyTextField.text!, completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if error != nil {
                        self.dummyTextField.becomeFirstResponder()
                        self.showErrorView()
                    } else {
                        let status = result?["success"] as? Int
                        if status != nil && status == 1 {
                            if let doctor = result?["doctor"] as? Dictionary<String, AnyObject> {
                                let user = User()
                                user.emailID = doctor["Email"] as? String
                                user.doctorTitle = doctor["DoctorTitle"] as? String
                                user.doctorType = doctor["DoctorType"] as? String
                                user.doctor_addr_city = doctor["Doctor_Addr_City"] as? String
                                user.doctor_addr_state = doctor["Doctor_Addr_State"] as? String
                                user.doctor_addr_street = doctor["Doctor_Addr_Street"] as? String
                                user.doctor_addr_unit = doctor["Doctor_Addr_Unit"] as? String
                                user.doctor_addr_zip = doctor["Doctor_Addr_Zip"] as? String
                                user.firstName = doctor["FirstName"] as? String
                                user.lastName = doctor["LastName"] as? String
                                user.phoneNumber = doctor["PhoneNo"] as? String
                                user.profilePicUrl = doctor["ProfilePicUrl"] as? String
                                user.userRole = doctor["UserRole"] as? String
                                user.dateOfBirth = doctor["dob"] as? String
                                self.doctorAddPermission(user: user)
                            }
                        } else {
                            self.dummyTextField.becomeFirstResponder()
                            
                            if let errorMsg = result?["err"] as? String {
                                if errorMsg == "already verified" {
                                    Utils.showAlert(title: "Error", message: "Chat room already exist with the user", viewController: self)
                                } else {
                                    self.showErrorView()
                                }
                            } else {
                                self.showErrorView()
                            }
                        }
                    }
                }
            })
        } else {
            self.dummyTextField.becomeFirstResponder()
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    
    func getRooms() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            DocTextApi.getRooms(senderId: Utils.getCurrentUser().emailID!, completionHandler: { (dict, error) in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if error != nil {
                        self.dummyTextField.becomeFirstResponder()
                        print("Error occured")
                    } else {
                        var conversations: [Conversation] = [Conversation]()
                        if let dictItems = dict {
                            for item in dictItems {
                            let conversation = Conversation()
                            conversation.roomName = item["roomName"] as? String
                            conversation.chatRoomId = item["room_id"] as? String
                            conversation.patientId = item["patientId"] as? String
                            conversation.doctorId = item["doctorId"] as? String
                            conversation.patientName = item["patientName"] as? String
                            conversation.doctorName = item["doctorName"] as? String
                            conversation.unreadCount = item["unreadCount"] as? Int
                            
                            if let lastMsg = item["lastMessage"] as? String {
                                conversation.lastMessage = lastMsg
                            } else {
                                conversation.lastMessage = ""
                            }
                            
                            if let lastMsg = item["lastMessageTime"] as? String {
                                conversation.lastMessageTime = lastMsg
                            } else {
                                conversation.lastMessageTime = ""
                            }
                            
                            if let userItem = item["receiverDetails"] as? Dictionary<String, AnyObject> {
                                conversation.convImageUrl = userItem["ProfilePicUrl"] as? String
                            }
                            
                            if let userItem = item["receiverDetails"] as? Dictionary<String, AnyObject> {
                                let user = User()
                                user.emailID = userItem["Email"] as? String
                                user.doctorTitle = userItem["DoctorTitle"] as? String
                                user.doctorType = userItem["DoctorType"] as? String
                                user.doctor_addr_city = userItem["Doctor_Addr_City"] as? String
                                user.doctor_addr_state = userItem["Doctor_Addr_State"] as? String
                                user.doctor_addr_street = userItem["Doctor_Addr_Street"] as? String
                                user.doctor_addr_unit = userItem["Doctor_Addr_Unit"] as? String
                                user.doctor_addr_zip = userItem["Doctor_Addr_Zip"] as? String
                                user.firstName = userItem["FirstName"] as? String
                                user.lastName = userItem["LastName"] as? String
                                user.phoneNumber = userItem["PhoneNo"] as? String
                                user.profilePicUrl = userItem["ProfilePicUrl"] as? String
                                user.userRole = userItem["UserRole"] as? String
                                user.dateOfBirth = userItem["dob"] as? String
                                conversation.userDetails = user
                            }
                            
                            conversations.append(conversation)
                            }
                        }
                        let myDict = [ "conversations": conversations]
                        NotificationCenter.default.post(name: Notification.Name("RefreshDashboardNotification"), object: myDict)
                        NotificationCenter.default.post(name: Notification.Name("RefreshPatientListNotification"), object: myDict)
                        
                            _ = self.navigationController?.popViewController(animated: true)
                        
                    }
                }
            })
        } else {
            self.dummyTextField.becomeFirstResponder()
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    func keyboardSize(size: CGSize) {
        self.nextBtnBCons.constant = size.height
        UIView.animate(withDuration: 0.50, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
}
