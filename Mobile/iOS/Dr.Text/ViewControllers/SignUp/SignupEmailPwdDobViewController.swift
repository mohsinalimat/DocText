//
//  SignupEmailPwdDobViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 29/11/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class SignupEmailPwdDobViewController: BaseViewController, customTextFieldProtocol, baseViewControllerProtocolDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- IBOutlets
    @IBOutlet weak var emailErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var emailErrorLbl: UILabel!
    
    @IBOutlet weak var passwordErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var passwordErrorLbl: UILabel!
    
    @IBOutlet weak var confirmPwdErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var confirmPwdErrorView: UIView!
    @IBOutlet weak var confirmPwdErrorLbl: UILabel!
    
    @IBOutlet weak var dobErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var dobErrorView: UIView!
    @IBOutlet weak var dobErrorLbl: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var emailTextFieldView: CustomTextFieldView!
    @IBOutlet weak var passwordTextFieldView: CustomTextFieldView!
    @IBOutlet weak var confirmPwdTextFieldView: CustomTextFieldView!
    @IBOutlet weak var dobTextFieldView: CustomTextFieldView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var datePicker = UIDatePicker()
    // MARK:- UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        datePicker.datePickerMode = .date
        datePicker.date = Utils.signupObj.dateOfBirth.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty ?  Date() : Utils.convertDateFromStringForDatePicker(dateString: Utils.signupObj.dateOfBirth)
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(SignupEmailPwdDobViewController.datePickerValueChange(datePicker:)), for: .valueChanged)
        
        emailTextFieldView.customTextfieldDelegate = self
        emailTextFieldView.textField.placeholder = "Email"
        emailTextFieldView.floatingLbl.text = "Email"
        emailTextFieldView.textField.keyboardType = .emailAddress
        emailTextFieldView.textField.autocapitalizationType = .none
        
        passwordTextFieldView.customTextfieldDelegate = self
        passwordTextFieldView.textField.placeholder = "Password"
        passwordTextFieldView.floatingLbl.text = "Password"
        passwordTextFieldView.textField.isSecureTextEntry = true
        passwordTextFieldView.isPassowrdField = true
        passwordTextFieldView.textField.textColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1)
        passwordTextFieldView.addShowTextViewInPassword()
        
        confirmPwdTextFieldView.customTextfieldDelegate = self
        confirmPwdTextFieldView.textField.placeholder = "Confirm Password"
        confirmPwdTextFieldView.floatingLbl.text = "Confirm Password"
        confirmPwdTextFieldView.textField.isSecureTextEntry = true
        confirmPwdTextFieldView.isPassowrdField = true
        confirmPwdTextFieldView.textField.textColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1)
        confirmPwdTextFieldView.addShowTextViewInPassword()
        
        dobTextFieldView.customTextfieldDelegate = self
        dobTextFieldView.textField.placeholder = "Date of Birth"
        dobTextFieldView.floatingLbl.text = "Date of Birth"
        dobTextFieldView.textField.inputView = datePicker
        
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 4)
        
        hideAllErrorView()
        self.activeField = emailTextFieldView.textField
    }
    
    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChangePWDViewController.actionOnTapGesture(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func actionOnTapGesture(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardDelegate = self
        navigationController?.isNavigationBarHidden = false
        progressView.progress = 0.0
        if !Utils.signupObj.emailID.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            emailTextFieldView.textField.text! = Utils.signupObj.emailID
            emailTextFieldView.showPositiveIndicator()
            emailTextFieldView.showTextFieldWithText()
        } else {
            emailTextFieldView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            passwordTextFieldView.textField.text! = Utils.signupObj.password
            passwordTextFieldView.showPositiveIndicator()
            passwordTextFieldView.showTextFieldWithText()
        } else {
            passwordTextFieldView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.confirmPWD.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            confirmPwdTextFieldView.textField.text! = Utils.signupObj.dateOfBirth
            confirmPwdTextFieldView.showPositiveIndicator()
            confirmPwdTextFieldView.showTextFieldWithText()
        } else {
            confirmPwdTextFieldView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.dateOfBirth.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            dobTextFieldView.textField.text! = Utils.signupObj.dateOfBirth
            dobTextFieldView.showPositiveIndicator()
            dobTextFieldView.showTextFieldWithText()
        } else {
            dobTextFieldView.hidePositiveIndicator()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressView.setProgress(Utils.getProgressPercentage(totoalVal: 5, currentVal: 2), animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        emailTextFieldView.textField.resignFirstResponder()
        passwordTextFieldView.textField.resignFirstResponder()
        confirmPwdTextFieldView.textField.resignFirstResponder()
        dobTextFieldView.textField.resignFirstResponder()
    }
    
    // MARK:- IBAction
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        moveToNextTextField()
    }
    
    // MARK:- Other Methods
    private func goToNextVC() {
        let signUpPhNoVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "SignUpPhNoViewController") as! SignUpPhNoViewController
        self.navigationController?.pushViewController(signUpPhNoVC, animated: true)
    }
    
    public func validateNextBtnStatus() {
        if (emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!  {
            showErrorMsgView(customTextFieldview: emailTextFieldView, message: EMPTY_EMAIL_ID)
        } else if !Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) {
            showErrorMsgView(customTextFieldview: emailTextFieldView, message: VALID_EMAIL_ID)
        } else if (passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: passwordTextFieldView, message: EMPTY_PASSWORD)
        } else if (passwordTextFieldView.textField.text!.characters.count < 8) {
            showErrorMsgView(customTextFieldview: passwordTextFieldView, message: PASSWORD_EIGHT_CHAR)
        } else if (confirmPwdTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: confirmPwdTextFieldView, message: EMPTY_CONFIRM_PASSWORD)
        } else if (confirmPwdTextFieldView.textField.text! != passwordTextFieldView.textField.text!) {
            showErrorMsgView(customTextFieldview: confirmPwdTextFieldView, message: PASSWORD_NOT_MATCH)
        } else if (dobTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: dobTextFieldView, message: EMPTY_DOB)
        } else if Utils.getAgeFromDate(birthday: dobTextFieldView.textField.text!) < 18  {
            showErrorMsgView(customTextFieldview: dobTextFieldView, message: DOB_18_YEARS)
        } else {
            checkUserExist()
        }
    }
    
    private func updateTFIndicator() {
        if (emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || !Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) {
            emailTextFieldView.hidePositiveIndicator()
        } else {
            emailTextFieldView.showPositiveIndicator()
        }
        
        if (passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (passwordTextFieldView.textField.text!.characters.count < 8) {
            passwordTextFieldView.hidePositiveIndicator()
        } else {
            passwordTextFieldView.showPositiveIndicator()
        }
        
        if (confirmPwdTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (confirmPwdTextFieldView.textField.text! == passwordTextFieldView.textField.text!) {
            confirmPwdTextFieldView.hidePositiveIndicator()
        } else {
            confirmPwdTextFieldView.showPositiveIndicator()
        }
        
        if (dobTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || Utils.getAgeFromDate(birthday: dobTextFieldView.textField.text!) < 18 {
            dobTextFieldView.hidePositiveIndicator()
        } else {
            dobTextFieldView.showPositiveIndicator()
        }
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        
        if emailTextFieldView.textField == textField {
            emailTextFieldView.placeHolderText = "Email"
            emailTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: emailTextFieldView)
        } else if passwordTextFieldView.textField == textField {
            passwordTextFieldView.placeHolderText = "Password"
            passwordTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: passwordTextFieldView)
            
        } else if confirmPwdTextFieldView.textField == textField {
            confirmPwdTextFieldView.placeHolderText = "Confirm Password"
            confirmPwdTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: confirmPwdTextFieldView)
            
        } else {
            dobTextFieldView.placeHolderText = "Date of Birth"
            dobTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: dobTextFieldView)
        }
        
        self.offSetForKeyboard = 40.0
        self.activeField = textField
    }
    
    func endTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        updateTFIndicator()
        if self.activeField == emailTextFieldView.textField {
            if (emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: emailTextFieldView, message: EMPTY_EMAIL_ID)
            } else if !Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) {
                showErrorMsgView(customTextFieldview: emailTextFieldView, message: VALID_EMAIL_ID)
            }
        } else if self.activeField == passwordTextFieldView.textField {
            
            if (passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: passwordTextFieldView, message: EMPTY_PASSWORD)
            } else if (passwordTextFieldView.textField.text!.characters.count < 8) {
                showErrorMsgView(customTextFieldview: passwordTextFieldView, message: PASSWORD_EIGHT_CHAR)
            }
        } else if self.activeField == confirmPwdTextFieldView.textField {
            if (confirmPwdTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: confirmPwdTextFieldView, message: EMPTY_CONFIRM_PASSWORD)
            } else if (confirmPwdTextFieldView.textField.text! != passwordTextFieldView.textField.text!) {
                showErrorMsgView(customTextFieldview: confirmPwdTextFieldView, message: PASSWORD_NOT_MATCH)
            }
        } else if self.activeField == dobTextFieldView.textField {
            if (dobTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: dobTextFieldView, message: EMPTY_DOB)
            } else if Utils.getAgeFromDate(birthday: dobTextFieldView.textField.text!) < 18  {
                showErrorMsgView(customTextFieldview: dobTextFieldView, message: DOB_18_YEARS)
            }
        }
    }
    
    func shouldReturnTextField(textField: UITextField) {
        moveToNextTextField()
    }
    
    func moveToNextTextField() {
        if !(emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) &&
            !(passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            (passwordTextFieldView.textField.text!.characters.count >= 8) &&
            !(confirmPwdTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            (confirmPwdTextFieldView.textField.text! == passwordTextFieldView.textField.text!) &&
            !(dobTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            Utils.getAgeFromDate(birthday: dobTextFieldView.textField.text!) >= 18  {
            validateNextBtnStatus()
        } else {
            if self.activeField == emailTextFieldView.textField {
                if (emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: emailTextFieldView, message: EMPTY_EMAIL_ID)
                } else if !Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) {
                    showErrorMsgView(customTextFieldview: emailTextFieldView, message: VALID_EMAIL_ID)
                } else {
                    passwordTextFieldView.textField.becomeFirstResponder()
                }
            } else if self.activeField == passwordTextFieldView.textField {
                if (passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: passwordTextFieldView, message: EMPTY_PASSWORD)
                } else if (passwordTextFieldView.textField.text!.characters.count < 8) {
                    showErrorMsgView(customTextFieldview: passwordTextFieldView, message: PASSWORD_EIGHT_CHAR)
                } else {
                    confirmPwdTextFieldView.textField.becomeFirstResponder()
                }
            } else if self.activeField == confirmPwdTextFieldView.textField {
                if (confirmPwdTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: confirmPwdTextFieldView, message: EMPTY_CONFIRM_PASSWORD)
                } else if (confirmPwdTextFieldView.textField.text! != passwordTextFieldView.textField.text!) {
                    showErrorMsgView(customTextFieldview: confirmPwdTextFieldView, message: PASSWORD_NOT_MATCH)
                } else {
                    dobTextFieldView.textField.becomeFirstResponder()
                }
            } else if self.activeField == dobTextFieldView.textField {
                if (dobTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: dobTextFieldView, message: EMPTY_DOB)
                } else if Utils.getAgeFromDate(birthday: dobTextFieldView.textField.text!) < 18  {
                    showErrorMsgView(customTextFieldview: dobTextFieldView, message: DOB_18_YEARS)
                } else {
                    validateNextBtnStatus()
                }
            }
        }
    }
    
    func editingChangedTextField(textField: UITextField) {
        if textField == emailTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: emailTextFieldView)
            emailTextFieldView.addSelectedConfig()
        } else if textField == passwordTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: passwordTextFieldView)
            passwordTextFieldView.addSelectedConfig()
        } else if textField == confirmPwdTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: confirmPwdTextFieldView)
            confirmPwdTextFieldView.addSelectedConfig()
        } else if textField == dobTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: dobTextFieldView)
            dobTextFieldView.addSelectedConfig()
        }
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    func datePickerValueChange(datePicker: UIDatePicker) {
        dobTextFieldView.textField.text = Utils.convertStringFromDateForDatePicker(date: datePicker.date)
        if Utils.getAgeFromDate(birthday: dobTextFieldView.textField.text!) < 18  {
            showErrorMsgView(customTextFieldview: dobTextFieldView, message: DOB_18_YEARS)
        } else {
            hideErrorMsgView(customTextFieldview: dobTextFieldView)
            dobTextFieldView.addSelectedConfig()
        }
    }
    
    func singleTap(sender: UITapGestureRecognizer) {
        
    }
    
    private func updateErrorMsgView(textField: UITextField) {
        if emailTextFieldView.textField == textField {
             if !(emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && !Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) {
                showErrorMsgView(customTextFieldview: emailTextFieldView, message: "Invalid email id")
             } else {
                hideErrorMsgView(customTextFieldview: emailTextFieldView)
            }
        } else if passwordTextFieldView.textField == textField {
             if !(passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && (passwordTextFieldView.textField.text!.characters.count < 8) {
                showErrorMsgView(customTextFieldview: passwordTextFieldView, message: "Must be contains at least 8 characters")
             } else {
                hideErrorMsgView(customTextFieldview: passwordTextFieldView)
            }
        } 
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == emailTextFieldView {
            emailErrorView.isHidden = false
            emailErrorHCons.constant = 40
            emailErrorLbl.text = message
            emailTextFieldView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == passwordTextFieldView {
            passwordErrorView.isHidden = false
            passwordErrorHCons.constant = 40
            passwordErrorLbl.text = message
            passwordTextFieldView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == confirmPwdTextFieldView {
            confirmPwdErrorView.isHidden = false
            confirmPwdErrorHCons.constant = 40
            confirmPwdErrorLbl.text = message
            confirmPwdTextFieldView.errorConfiguration()
            adjustLayouts()
        } else {
            dobErrorView.isHidden = false
            dobErrorHCons.constant = 40
            dobErrorLbl.text = message
            dobTextFieldView.errorConfiguration()
            adjustLayouts()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == emailTextFieldView {
            emailErrorView.isHidden = true
            emailErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == passwordTextFieldView {
            passwordErrorView.isHidden = true
            passwordErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == confirmPwdTextFieldView {
            confirmPwdErrorView.isHidden = true
            confirmPwdErrorHCons.constant = 0
            adjustLayouts()
        } else {
            dobErrorView.isHidden = true
            dobErrorHCons.constant = 0
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
    
    func hideAllErrorView() {
        hideErrorMsgView(customTextFieldview: emailTextFieldView)
        hideErrorMsgView(customTextFieldview: passwordTextFieldView)
        hideErrorMsgView(customTextFieldview: confirmPwdTextFieldView)
        hideErrorMsgView(customTextFieldview: dobTextFieldView)
    }
    
    func checkUserExist() {
        passwordTextFieldView.textField.resignFirstResponder()
        emailTextFieldView.textField.resignFirstResponder()
        confirmPwdTextFieldView.textField.resignFirstResponder()
        dobTextFieldView.textField.resignFirstResponder()
        hideAllErrorView()
        
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            DocTextApi.checkUserExistOrNot(emailID: self.emailTextFieldView.textField.text!, completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if error != nil {
                        Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                    } else {
                        if let isExist = result?["isExist"] as? Int {
                            if isExist == 1 {
                                self.showErrorMsgView(customTextFieldview: self.emailTextFieldView, message: ACCOUNT_EXIST)
                            } else {
                                Utils.signupObj.emailID = self.emailTextFieldView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                Utils.signupObj.password   = self.passwordTextFieldView.textField.text!
                                Utils.signupObj.dateOfBirth = self.dobTextFieldView.textField.text!
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
