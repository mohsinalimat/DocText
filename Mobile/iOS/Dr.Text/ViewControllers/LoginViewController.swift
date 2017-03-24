//
//  LoginViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 10/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognitoIdentityProvider

class LoginViewController: BaseViewController, customTextFieldProtocol, AWSCognitoIdentityPasswordAuthentication, baseViewControllerProtocolDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- IBOutlets
    @IBOutlet weak var emailErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var emailErrorLbl: UILabel!
    
    @IBOutlet weak var passwordErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var passwordErrorLbl: UILabel!
    
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!

    @IBOutlet weak var emailTextFieldView: CustomTextFieldView!
    @IBOutlet weak var passwordTextFieldView: CustomTextFieldView!
    @IBOutlet weak var nextBtn: UIButton!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>! = AWSTaskCompletionSource.init()
    var delegate: hideHUDDelegate?
    
    // MARK:- UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        delegate = appdelegate.introductionViewController
        
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
        
        hideAllErrorView()
        self.activeField = emailTextFieldView.textField
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardDelegate = self
        navigationController?.isNavigationBarHidden = false
        
        emailTextFieldView.textField.text = ""
        emailTextFieldView.placeHolderText = "Email"
        passwordTextFieldView.textField.text = ""
        passwordTextFieldView.placeHolderText = "Password"
        
        emailTextFieldView.textField.resignFirstResponder()
        passwordTextFieldView.textField.resignFirstResponder()
        
        passwordTextFieldView.hidePositiveIndicator()
        emailTextFieldView.hidePositiveIndicator()
        passwordTextFieldView.hideTextFieldWithText()
        emailTextFieldView.hideTextFieldWithText()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        emailTextFieldView.textField.resignFirstResponder()
        passwordTextFieldView.textField.resignFirstResponder()
    }
    
    
    // MARK:- IBActions
    override func actionOnBackBtn(sender: UIBarButtonItem) {
        AWSCognitoIdentityUserPool(forKey: "UserPool").currentUser()?.signOut()
        self.delegate?.hideAllHud()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        moveToNextTextField()
    }
    
    @IBAction func actionOnDoneBtn(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func actionOnForgotPwd(_ sender: UIButton) {
        emailTextFieldView.textField.resignFirstResponder()
        passwordTextFieldView.textField.resignFirstResponder()
        
        let createNewPwdVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "RequestNewPWDViewController")
        self.navigationController?.pushViewController(createNewPwdVC, animated: true)
    }
    
    // MARK:- Other Methods
    func validateNextBtnStatus() {
        
        if (emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: emailTextFieldView, message: EMPTY_EMAIL_ID)
        } else if (passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!  {
            showErrorMsgView(customTextFieldview: passwordTextFieldView, message: EMPTY_PASSWORD)
        } else {
            emailTextFieldView.textField.resignFirstResponder()
            passwordTextFieldView.textField.resignFirstResponder()
            
            goToNextVC()
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
    }
    
    private func goToNextVC() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            let user = User()
            user.emailID = emailTextFieldView.textField.text!
            Utils.setCurrentUser(currentUser: user)
            
            Utils.signupObj.emailID = emailTextFieldView.textField.text!
            Utils.signupObj.password = passwordTextFieldView.textField.text!
            
            self.passwordAuthenticationCompletion.setResult(AWSCognitoIdentityPasswordAuthenticationDetails(username: emailTextFieldView.textField.text!, password: passwordTextFieldView.textField.text!))
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    // MARK:- Cognito Delegate Methods
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if error != nil {
                Utils.hideHUD(view: self.view)
                print("Domain: " + ((error as! NSError).domain) + " Code: \((error as! NSError).code)")
                let errorMessage = ((error as! NSError).userInfo["message"] as? String)!
                print(errorMessage)
                
                if errorMessage == "User is not confirmed." {
                    let alertController = UIAlertController(title: "Authentication Error", message: errorMessage, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                        print("you have pressed the Cancel button");
                    }
                    alertController.addAction(cancelAction)
                    
                    let OKAction = UIAlertAction(title: "Confirm", style: .default) { (action:UIAlertAction!) in
                        self.sendVerificationCode()
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion:nil)
                } else {
                    Utils.showAlert(title: "Authentication Error", message: errorMessage, viewController: self)
                }
            } else {
            }
        }
    }
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    func sendVerificationCode() {
        let user = Utils.getUserPool().getUser(emailTextFieldView.textField.text!)
        print(user.username!)
        
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            user.resendConfirmationCode().continue({ (task) -> Any? in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if task.error != nil {
                        
                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                        print(((task.error as! NSError).userInfo["message"] as? String)!)
                        Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                    } else {
                        let confirmationCodeVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ConfirmationViewController") as! ConfirmationViewController
                        confirmationCodeVC.identityUser = user
                        self.navigationController?.pushViewController(confirmationCodeVC, animated: true)
                    }
                }
                return nil
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
        
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        self.offSetForKeyboard = 20.0
        
        if emailTextFieldView.textField == textField {
            emailTextFieldView.placeHolderText = "Email"
            emailTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: emailTextFieldView)
        } else if passwordTextFieldView.textField == textField {
            passwordTextFieldView.placeHolderText = "Password"
            passwordTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: passwordTextFieldView)
        }
    }
    
    func endTextFieldEditing(textField: UITextField) {
        textField.resignFirstResponder()
        self.activeField = textField
        updateTFIndicator()
        
        if self.activeField == emailTextFieldView.textField {
            if (emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: emailTextFieldView, message: EMPTY_EMAIL_ID)
            }
        } else if self.activeField == passwordTextFieldView.textField {
            if (passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: passwordTextFieldView, message: EMPTY_PASSWORD)
            }
        }
    }
    
    func shouldReturnTextField(textField: UITextField) {
        moveToNextTextField()
    }
    
    func editingChangedTextField(textField: UITextField) {
        if textField == emailTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: emailTextFieldView)
            emailTextFieldView.addSelectedConfig()
        } else if textField == passwordTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: passwordTextFieldView)
            passwordTextFieldView.addSelectedConfig()
        }
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    func moveToNextTextField() {
        
        if !(emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            !(passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            validateNextBtnStatus()
        } else {
            if self.activeField == emailTextFieldView.textField {
                if (emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: emailTextFieldView, message: EMPTY_EMAIL_ID)
                } else {
                    self.passwordTextFieldView.textField.becomeFirstResponder()
                }
            } else if self.activeField == passwordTextFieldView.textField {
                if (passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: passwordTextFieldView, message: EMPTY_PASSWORD)
                }
            }
        }
    }
    
    func showErrorMessage(message: String) {
        Utils.notification?.display(withMessage: message, forDuration: 3)
    }
    
    func validateEachTextField() {
        if self.activeField == emailTextFieldView.textField {
            if (emailTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMessage(message: "Please enter your email address")
            } else if !Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) {
                showErrorMessage(message: "Please enter your valid email address")
            }
        } else {
            if (passwordTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMessage(message: "Please enter your password")
            } else if (passwordTextFieldView.textField.text!.characters.count < 8) {
                showErrorMessage(message: "Password must contains at least 8 characters")
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
    }
    
    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChangePWDViewController.actionOnTapGesture(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func actionOnTapGesture(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }

}
