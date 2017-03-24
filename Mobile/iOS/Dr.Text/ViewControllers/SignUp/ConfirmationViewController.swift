//
//  ConfirmationViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 10/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ConfirmationViewController: BaseViewController, UITextFieldDelegate, baseViewControllerProtocolDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- IBOutlets
    @IBOutlet weak var resendCodeTCons: NSLayoutConstraint!
    public var identityUser: AWSCognitoIdentityUser?
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var fristDigitLbl: UILabel!
    @IBOutlet weak var secondDigitLbl: UILabel!
    @IBOutlet weak var thirdDigitLbl: UILabel!
    @IBOutlet weak var fourthDigitLbl: UILabel!
    @IBOutlet weak var fifthDigitLbl: UILabel!
    @IBOutlet weak var sixthDigitLbl: UILabel!
    @IBOutlet weak var dummyTextField: dumTextField!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!

    // MARK:- UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        dummyTextField.becomeFirstResponder()
        dummyTextField.addTarget(self, action: #selector(textChangedAction), for: .editingChanged)
        errorView.isHidden = true
        
        setEmptyLblProperty(label: fristDigitLbl)
        setEmptyLblProperty(label: secondDigitLbl)
        setEmptyLblProperty(label: thirdDigitLbl)
        setEmptyLblProperty(label: fourthDigitLbl)
        setEmptyLblProperty(label: fifthDigitLbl)
        setEmptyLblProperty(label: sixthDigitLbl)
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 4)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressView.progress = 0.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressView.setProgress(Utils.signupObj.userRole == "Patient" ? Utils.getProgressPercentage(totoalVal: 5, currentVal: 4) : Utils.getProgressPercentage(totoalVal: 7, currentVal: 6), animated: true)
    }
    
    // MARK:- IBAction
    @IBAction func actionOnResendCode(_ sender: UIButton) {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            identityUser?.resendConfirmationCode().continue({ (task) -> Any? in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if task.error != nil {
                        
                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                        print(((task.error as! NSError).userInfo["message"] as? String)!)
                        Utils.showAlert(title: "Error Found", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                    } else {
                        let response: AWSCognitoIdentityUserResendConfirmationCodeResponse = task.result!
                        let resentTo = response.codeDeliveryDetails?.destination
                        Utils.showAlert(title: "", message: "Code resent to: \(resentTo!)", viewController: self)
                    }
                }
                return nil
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChangePWDViewController.actionOnTapGesture(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func actionOnTapGesture(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
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
        moveResendBtnToTop()
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
            confirmSignUp()
        }
    }
    
    func confirmSignUp() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            dummyTextField.resignFirstResponder()
            Utils.showHUD(view: self.view)
            identityUser?.confirmSignUp(dummyTextField.text!, forceAliasCreation: true).continue({ (task) -> Any? in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if task.error != nil {
                        self.showErrorView()
                        self.dummyTextField.becomeFirstResponder()
                    } else {
                        Utils.getUserPool().currentUser()?.getSession(Utils.signupObj.emailID, password: Utils.signupObj.password, validationData: nil)
                        print(self.identityUser?.isSignedIn ?? "123")
                        
                        print((Utils.getUserPool().currentUser()?.isSignedIn)!)
                        self.getUserDetails()
                    }
                }
                return nil
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    func getUserDetails() {
        Utils.showHUD(view: self.view)
        DocTextApi.getUserDetails(userId: Utils.user.emailID!) { (result, error) in
            DispatchQueue.main.async {
                Utils.hideHUD(view: self.view)
                if error != nil {
                    self.dummyTextField.becomeFirstResponder()
                    Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                } else {
                    print( (Utils.getUserPool().currentUser()?.isSignedIn)!)
                    if let item = result?["Item"] as? Dictionary<String, Any> {
                        let user = User()
                        user.userRole = item["UserRole"] as? String
                        user.lastName = item["LastName"] as? String
                        user.firstName = item["FirstName"] as? String
                        user.phoneNumber = item["PhoneNo"] as? String
                        user.emailID = item["Email"] as? String
                        user.dateOfBirth = item["dob"] as? String
                        user.doctorTitle = item["DoctorTitle"] as? String
                        user.doctorType = item["DoctorType"] as? String
                        user.doctorCharge = item["DoctorCharge"] as? String
                        user.phCountryCode = item["PhNo_Country_Code"] as? String
                        user.doctor_addr_street = item["Doctor_Addr_Street"] as? String
                        user.doctor_addr_unit = item["Doctor_Addr_Unit"] as? String
                        user.doctor_addr_city = item["Doctor_Addr_City"] as? String
                        user.doctor_addr_state = item["Doctor_Addr_State"] as? String
                        user.doctor_addr_zip = item["Doctor_Addr_Zip"] as? String
                        user.doctor_office_phno = item["Doctor_Office_PhNo"] as? String
                        user.cardId = (item["StripeCardId"] as? String) == nil ? "nil" : item["StripeCardId"] as? String
                        user.customerId = (item["StripeCustomerId"] as? String) == nil ? "nil" : item["StripeCustomerId"] as? String
                        user.iSCardWorking = true
                        
                        Utils.setCurrentUser(currentUser: user)
                        Utils.sendDeviceToken()
                        
                        if Utils.user.userRole == "Patient" {
                            let tabbarVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                            tabbarVC.selectedIndex = 2
                            tabbarVC.modalPresentationStyle = .custom
                            tabbarVC.modalTransitionStyle = .crossDissolve
                            
                            let navigationController = UINavigationController(rootViewController: tabbarVC)
                            navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.9907117486, green: 0.8272568583, blue: 0.349744916, alpha: 1)
                            navigationController.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                            navigationController.navigationBar.isTranslucent = false
                            
                            self.present(navigationController, animated: true, completion: nil)
                        } else {
                            let doctorChargeVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorChargeViewController") as! DoctorChargeViewController
                            doctorChargeVC.isUpdateCharge = false
                            self.navigationController?.pushViewController(doctorChargeVC, animated: true)
                        }
                    }
                }
            }
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
        moveResendBtnToBottom()
        errorView.isHidden = false
        setErrorLblProperty(label: fristDigitLbl)
        setErrorLblProperty(label: secondDigitLbl)
        setErrorLblProperty(label: thirdDigitLbl)
        setErrorLblProperty(label: fourthDigitLbl)
        setErrorLblProperty(label: fifthDigitLbl)
        setErrorLblProperty(label: sixthDigitLbl)
    }
    
    func hideErrorView() {
        moveResendBtnToTop()
        errorView.isHidden = true
        dummyTextField.text = ""
        setEmptyLblProperty(label: fristDigitLbl)
        setEmptyLblProperty(label: secondDigitLbl)
        setEmptyLblProperty(label: thirdDigitLbl)
        setEmptyLblProperty(label: fourthDigitLbl)
        setEmptyLblProperty(label: fifthDigitLbl)
        setEmptyLblProperty(label: sixthDigitLbl)
    }
    
    func moveResendBtnToBottom() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
            self.resendCodeTCons.constant = 44.0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveResendBtnToTop() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
            self.resendCodeTCons.constant = 14.0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    @IBAction func actionOnTryAgain(_ sender: UIButton) {
        hideErrorView()
    }
    
    func keyboardSize(size: CGSize) {
        self.nextBtnBCons.constant = size.height
        UIView.animate(withDuration: 0.50, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
}

class dumTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
