//
//  CreateNewPWDViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 01/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

protocol ResetPwdProtocolDelegate {
    func verificationCodeError()
}

class CreateNewPWDViewController: BaseViewController, customTextFieldProtocol, baseViewControllerProtocolDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var passwordErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var passwordErrorLbl: UILabel!

    @IBOutlet weak var confirmPwdErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var confirmPwdErrorView: UIView!
    @IBOutlet weak var confirmPwdErrorLbl: UILabel!

    @IBOutlet weak var passwordView: CustomTextFieldView!
    @IBOutlet weak var confirmPwdView: CustomTextFieldView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    
    var resetPWDDelegate: ResetPwdProtocolDelegate?
    var delegate: hideHUDDelegate?
    var emailID: String!
    var code: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTapGesture()
        setBackButton()
        self.keyboardDelegate = self

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
        hideAllErrorView()
        self.activeField = passwordView.textField
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        passwordView.textField.resignFirstResponder()
        confirmPwdView.textField.resignFirstResponder()
    }
    
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        moveToNextTextField()
    }
    
    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChangePWDViewController.actionOnTapGesture(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func actionOnTapGesture(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    // MARK:- Other Methods
    public func validateNextBtnStatus() {
        if  (passwordView.textField.text?.isEmpty)! {
            showErrorMsgView(customTextFieldview: passwordView, message: EMPTY_PASSWORD)
        } else if (confirmPwdView.textField.text?.isEmpty)! {
            showErrorMsgView(customTextFieldview: passwordView, message: EMPTY_CONFIRM_PASSWORD)
        } else if (passwordView.textField.text!.characters.count < 8) {
            showErrorMsgView(customTextFieldview: passwordView, message: PASSWORD_EIGHT_CHAR)
        } else if (confirmPwdView.textField.text!.characters.count < 8) {
            showErrorMsgView(customTextFieldview: passwordView, message: PASSWORD_EIGHT_CHAR)
        } else if (confirmPwdView.textField.text! != passwordView.textField.text!) {
            showErrorMsgView(customTextFieldview: passwordView, message: PASSWORD_NOT_MATCH)
        } else {
            passwordView.textField.resignFirstResponder()
            confirmPwdView.textField.resignFirstResponder()
            changePassword()
        }
    }
    
    private func updateTFIndicator() {
        if (passwordView.textField.text?.isEmpty)! || (passwordView.textField.text!.characters.count < 8) {
            passwordView.hidePositiveIndicator()
        } else {
            passwordView.showPositiveIndicator()
        }
        
        if (confirmPwdView.textField.text?.isEmpty)! || (confirmPwdView.textField.text!.characters.count < 8) || (confirmPwdView.textField.text! != passwordView.textField.text!) {
            confirmPwdView.hidePositiveIndicator()
        } else {
            confirmPwdView.showPositiveIndicator()
        }
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        self.offSetForKeyboard = 20.0
        
        if passwordView.textField == textField {
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
        if self.activeField == passwordView.textField {
            
            if (passwordView.textField.text?.isEmpty)! {
                showErrorMsgView(customTextFieldview: passwordView, message: EMPTY_PASSWORD)
            } else if (passwordView.textField.text!.characters.count < 8) {
                showErrorMsgView(customTextFieldview: passwordView, message: PASSWORD_EIGHT_CHAR)
            }
        } else if self.activeField == confirmPwdView.textField {
            if (confirmPwdView.textField.text?.isEmpty)! {
                showErrorMsgView(customTextFieldview: confirmPwdView, message: EMPTY_CONFIRM_PASSWORD)
            } else if (confirmPwdView.textField.text! != passwordView.textField.text!) {
                showErrorMsgView(customTextFieldview: confirmPwdView, message: PASSWORD_NOT_MATCH)
            }
        }
    }
    
    func shouldReturnTextField(textField: UITextField) {
        moveToNextTextField()
    }
    
    func editingChangedTextField(textField: UITextField) {
        if textField == passwordView.textField {
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
    
    func moveToNextTextField() {
        if !(passwordView.textField.text?.isEmpty)! &&
            (passwordView.textField.text!.characters.count >= 8) &&
            !(confirmPwdView.textField.text?.isEmpty)! &&
            (confirmPwdView.textField.text! == passwordView.textField.text!) {
            validateNextBtnStatus()
        } else {
            if self.activeField == passwordView.textField {
                if (passwordView.textField.text?.isEmpty)! {
                    showErrorMsgView(customTextFieldview: passwordView, message: EMPTY_PASSWORD)
                } else if (passwordView.textField.text!.characters.count < 8) {
                    showErrorMsgView(customTextFieldview: passwordView, message: PASSWORD_EIGHT_CHAR)
                } else {
                    confirmPwdView.textField.becomeFirstResponder()
                }
            } else if self.activeField == confirmPwdView.textField {
                if (confirmPwdView.textField.text?.isEmpty)! {
                    showErrorMsgView(customTextFieldview: confirmPwdView, message: EMPTY_CONFIRM_PASSWORD)
                } else if (confirmPwdView.textField.text! != passwordView.textField.text!) {
                    showErrorMsgView(customTextFieldview: confirmPwdView, message: PASSWORD_NOT_MATCH)
                } else {
                    validateNextBtnStatus()
                }
            }
        }
    }
    
    func changePassword() {
        passwordView.textField.resignFirstResponder()
        confirmPwdView.textField.resignFirstResponder()
        
        let user = Utils.getUserPool().getUser(emailID)
        
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)            
            user.confirmForgotPassword(code, password: confirmPwdView.textField.text!).continue({ (task) -> Any? in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if task.error != nil {
                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                        print(((task.error as! NSError).userInfo["message"] as? String)!)
                        
                        if ((task.error as! NSError).userInfo["message"] as? String)! == "Invalid verification code provided, please try again." {
                            let alertController = UIAlertController(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                                if self.resetPWDDelegate != nil {
                                    self.resetPWDDelegate?.verificationCodeError()
                                    _ = self.navigationController?.popViewController(animated: true)
                                }
                            }
                            alertController.addAction(OKAction)
                            self.present(alertController, animated: true, completion:nil)
                        } else {
                            Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                        }
                    } else {
                        print("verification code for forgot password sent successfully")
                        let alertController = UIAlertController(title: "Success!", message: "Your password has been reset.", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                            self.delegate?.hideAllHud()
                            
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
                }
                return nil
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == passwordView {
            passwordErrorView.isHidden = false
            passwordErrorHCons.constant = 40
            passwordErrorLbl.text = message
            passwordView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == confirmPwdView {
            confirmPwdErrorView.isHidden = false
            confirmPwdErrorHCons.constant = 40
            confirmPwdErrorLbl.text = message
            confirmPwdView.errorConfiguration()
            adjustLayouts()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == passwordView {
            passwordErrorView.isHidden = true
            passwordErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == confirmPwdView {
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
    
    func hideAllErrorView() {
        hideErrorMsgView(customTextFieldview: passwordView)
        hideErrorMsgView(customTextFieldview: confirmPwdView)
    }
}
