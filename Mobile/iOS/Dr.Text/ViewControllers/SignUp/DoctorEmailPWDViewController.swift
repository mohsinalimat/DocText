//
//  DoctorEmailPWDViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 07/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class DoctorEmailPWDViewController: BaseViewController, customTextFieldProtocol, baseViewControllerProtocolDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var emailErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var emailErrorLbl: UILabel!
    
    @IBOutlet weak var passwordErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var passwordErrorLbl: UILabel!
    
    @IBOutlet weak var confirmPwdErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var confirmPwdErrorView: UIView!
    @IBOutlet weak var confirmPwdErrorLbl: UILabel!
    
    @IBOutlet weak var emailView: CustomTextFieldView!
    @IBOutlet weak var passwordView: CustomTextFieldView!
    @IBOutlet weak var confirmPwdView: CustomTextFieldView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        
        emailView.customTextfieldDelegate = self
        emailView.textField.placeholder = "Email"
        emailView.floatingLbl.text = "Email"
        emailView.textField.keyboardType = .emailAddress
        emailView.textField.autocapitalizationType = .none
        
        passwordView.customTextfieldDelegate = self
        passwordView.textField.placeholder = "Password"
        passwordView.floatingLbl.text = "Password"
        passwordView.textField.isSecureTextEntry = true
        passwordView.isPassowrdField = true
        passwordView.textField.textColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1)
        passwordView.addShowTextViewInPassword()
        
        confirmPwdView.customTextfieldDelegate = self
        confirmPwdView.textField.placeholder = "Confirm Password"
        confirmPwdView.floatingLbl.text = "Confirm Password"
        confirmPwdView.textField.isSecureTextEntry = true
        confirmPwdView.isPassowrdField = true
        confirmPwdView.textField.textColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1)
        confirmPwdView.addShowTextViewInPassword()
        
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 4)
        progressView.progress = Utils.getProgressPercentage(totoalVal: 7, currentVal: 3)
        
        hideErrorMsgView(customTextFieldview: emailView)
        hideErrorMsgView(customTextFieldview: passwordView)
        hideErrorMsgView(customTextFieldview: confirmPwdView)
        self.activeField = emailView.textField
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardDelegate = self
        navigationController?.isNavigationBarHidden = false
        progressView.progress = 0.0
        if !Utils.signupObj.emailID.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            emailView.textField.text! = Utils.signupObj.emailID
            emailView.showPositiveIndicator()
            emailView.showTextFieldWithText()
        } else {
            emailView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            passwordView.textField.text! = Utils.signupObj.password
            passwordView.showPositiveIndicator()
            passwordView.showTextFieldWithText()
        } else {
            passwordView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.confirmPWD.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            confirmPwdView.textField.text! = Utils.signupObj.confirmPWD
            confirmPwdView.showPositiveIndicator()
            confirmPwdView.showTextFieldWithText()
        } else {
            confirmPwdView.hidePositiveIndicator()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewWCons.constant = (self.scrollView?.frame.width)!
        containerViewHCons.constant = (self.scrollView?.frame.height)!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressView.setProgress(Utils.getProgressPercentage(totoalVal: 7, currentVal: 4), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        emailView.textField.resignFirstResponder()
        passwordView.textField.resignFirstResponder()
        confirmPwdView.textField.resignFirstResponder()
    }
    
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        moveToNextTextField()
    }
    
    // MARK:- Other Methods
    private func goToNextVC() {
        let signUpPhNoVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "SignUpPhNoViewController") as! SignUpPhNoViewController
        self.navigationController?.pushViewController(signUpPhNoVC, animated: true)
    }
    
    public func validateNextBtnStatus() {
        if (emailView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: emailView, message: EMPTY_EMAIL_ID)
        } else if !Utils.isValidEmail(emailId: emailView.textField.text!) {
            showErrorMsgView(customTextFieldview: emailView, message: VALID_EMAIL_ID)
        } else if (passwordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: emailView, message: EMPTY_PASSWORD)
        } else if (passwordView.textField.text!.characters.count < 8) {
            showErrorMsgView(customTextFieldview: emailView, message: PASSWORD_EIGHT_CHAR)
        } else if (confirmPwdView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: emailView, message: EMPTY_CONFIRM_PASSWORD)
        } else if (confirmPwdView.textField.text!.characters.count < 8) {
            showErrorMsgView(customTextFieldview: emailView, message: PASSWORD_EIGHT_CHAR)
        } else if (confirmPwdView.textField.text! != passwordView.textField.text!) {
            showErrorMsgView(customTextFieldview: emailView, message: PASSWORD_NOT_MATCH)
        } else {
            checkUserExist()
        }
    }
    
    private func updateTFIndicator() {
        if (emailView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || !Utils.isValidEmail(emailId: emailView.textField.text!) {
            emailView.hidePositiveIndicator()
        } else {
            emailView.showPositiveIndicator()
        }
        
        if (passwordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (passwordView.textField.text!.characters.count < 8) {
            passwordView.hidePositiveIndicator()
        } else {
            passwordView.showPositiveIndicator()
        }
        
        if (confirmPwdView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (confirmPwdView.textField.text!.characters.count < 8) || (confirmPwdView.textField.text! != passwordView.textField.text!) {
            confirmPwdView.hidePositiveIndicator()
        } else {
            confirmPwdView.showPositiveIndicator()
        }
    }
    
    func singleTap(sender: UITapGestureRecognizer) {
        emailView.textField.resignFirstResponder()
        passwordView.textField.resignFirstResponder()
        confirmPwdView.textField.resignFirstResponder()
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        self.offSetForKeyboard = 35.0
        
        if emailView.textField == textField {
            emailView.placeHolderText = "Email"
            emailView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: emailView)
            
        } else if passwordView.textField == textField {
            passwordView.placeHolderText = "Password"
            passwordView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: passwordView)
            
        } else {
            confirmPwdView.placeHolderText = "Confirm Password"
            confirmPwdView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: confirmPwdView)
            
        }
    }
    
    func endTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        updateTFIndicator()
        
        if self.activeField == emailView.textField {
            if (emailView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: emailView, message: EMPTY_EMAIL_ID)
            } else if !Utils.isValidEmail(emailId: emailView.textField.text!) {
                showErrorMsgView(customTextFieldview: emailView, message: VALID_EMAIL_ID)
            }
        } else if self.activeField == passwordView.textField {
            if (passwordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: passwordView, message: EMPTY_PASSWORD)
            } else if (passwordView.textField.text!.characters.count < 8) {
                showErrorMsgView(customTextFieldview: passwordView, message: PASSWORD_EIGHT_CHAR)
            }
        } else if self.activeField == confirmPwdView.textField {
            if (confirmPwdView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: confirmPwdView, message: EMPTY_CONFIRM_PASSWORD)
            } else if (confirmPwdView.textField.text! != passwordView.textField.text!) {
                showErrorMsgView(customTextFieldview: confirmPwdView, message: PASSWORD_NOT_MATCH)
            }
        }
    }
    
    func shouldReturnTextField(textField: UITextField) {
        moveToNextTextField()
    }
    
    func moveToNextTextField() {
        
        if !(emailView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            Utils.isValidEmail(emailId: emailView.textField.text!) &&
            !(passwordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            (passwordView.textField.text!.characters.count >= 8) &&
            !(confirmPwdView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            (confirmPwdView.textField.text! == passwordView.textField.text!) {
            validateNextBtnStatus()
        } else {
            if self.activeField == emailView.textField {
                if (emailView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: emailView, message: EMPTY_EMAIL_ID)
                } else if !Utils.isValidEmail(emailId: emailView.textField.text!) {
                    showErrorMsgView(customTextFieldview: emailView, message: VALID_EMAIL_ID)
                } else {
                    passwordView.textField.becomeFirstResponder()
                }
            } else if self.activeField == passwordView.textField {
                if (passwordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: passwordView, message: EMPTY_PASSWORD)
                } else if (passwordView.textField.text!.characters.count < 8) {
                    showErrorMsgView(customTextFieldview: passwordView, message: PASSWORD_EIGHT_CHAR)
                } else {
                    confirmPwdView.textField.becomeFirstResponder()
                }
            } else if self.activeField == confirmPwdView.textField {
                if (confirmPwdView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: confirmPwdView, message: EMPTY_CONFIRM_PASSWORD)
                } else if (confirmPwdView.textField.text! != passwordView.textField.text!) {
                    showErrorMsgView(customTextFieldview: confirmPwdView, message: PASSWORD_NOT_MATCH)
                } else {
                    validateNextBtnStatus()
                }
            }
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
    
    func editingChangedTextField(textField: UITextField) {
        if textField == emailView.textField {
            hideErrorMsgView(customTextFieldview: emailView)
            emailView.addSelectedConfig()
        } else if textField == passwordView.textField {
            hideErrorMsgView(customTextFieldview: passwordView)
            passwordView.addSelectedConfig()
        } else if textField == confirmPwdView.textField {
            hideErrorMsgView(customTextFieldview: confirmPwdView)
            confirmPwdView.addSelectedConfig()
        }
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    
    
    private func updateErrorMsgView(textField: UITextField) {
        if emailView.textField == textField {
             if !(emailView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && !Utils.isValidEmail(emailId: emailView.textField.text!) {
                showErrorMsgView(customTextFieldview: emailView, message: "Invalid email id")
             } else {
                hideErrorMsgView(customTextFieldview: emailView)
            }
        } else if passwordView.textField == textField {
             if !(passwordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && (passwordView.textField.text!.characters.count < 8) {
                showErrorMsgView(customTextFieldview: passwordView, message: "Must be contains at least 8 characters")
             } else {
                hideErrorMsgView(customTextFieldview: passwordView)
            }
        } else {
             if !(confirmPwdView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&  (confirmPwdView.textField.text!.characters.count < 8) {
                showErrorMsgView(customTextFieldview: confirmPwdView, message: "Must be contains at least 8 characters")
             } else if !(confirmPwdView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&  (confirmPwdView.textField.text! != passwordView.textField.text!) {
                showErrorMsgView(customTextFieldview: confirmPwdView, message: "Password doesn't match")
             } else {
                hideErrorMsgView(customTextFieldview: confirmPwdView)
            }
        }
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == emailView {
            emailErrorView.isHidden = false
            emailErrorHCons.constant = 40
            emailErrorLbl.text = message
            emailView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == passwordView {
            passwordErrorView.isHidden = false
            passwordErrorHCons.constant = 40
            passwordErrorLbl.text = message
            passwordView.errorConfiguration()
            adjustLayouts()
        } else {
            confirmPwdErrorView.isHidden = false
            confirmPwdErrorHCons.constant = 40
            confirmPwdErrorLbl.text = message
            confirmPwdView.errorConfiguration()
            adjustLayouts()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == emailView {
            emailErrorView.isHidden = true
            emailErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == passwordView {
            passwordErrorView.isHidden = true
            passwordErrorHCons.constant = 0
            adjustLayouts()
        } else {
            confirmPwdErrorView.isHidden = true
            confirmPwdErrorHCons.constant = 0
            adjustLayouts()
        }
    }
    
    func keyboardSize(size: CGSize) {
        self.nextBtnBCons.constant = size.height
        UIView.animate(withDuration: 0.50, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    func checkUserExist() {
        emailView.textField.resignFirstResponder()
        passwordView.textField.resignFirstResponder()
        confirmPwdView.textField.resignFirstResponder()
        hideErrorMsgView(customTextFieldview: emailView)
        hideErrorMsgView(customTextFieldview: passwordView)
        hideErrorMsgView(customTextFieldview: confirmPwdView)
        
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            DocTextApi.checkUserExistOrNot(emailID: self.emailView.textField.text!, completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if error != nil {
                        Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                    } else {
                        if let isExist = result?["isExist"] as? Int {
                            if isExist == 1 {
                                self.showErrorMsgView(customTextFieldview: self.emailView, message: ACCOUNT_EXIST)
                            } else {
                                Utils.signupObj.emailID = self.emailView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                Utils.signupObj.password   = self.passwordView.textField.text!
                                Utils.signupObj.confirmPWD = self.confirmPwdView.textField.text!
                                self.goToNextVC()
                            }
                        }
                    }
                    
                }
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
}
