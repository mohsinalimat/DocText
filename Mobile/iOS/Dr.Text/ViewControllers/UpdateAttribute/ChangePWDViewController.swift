//
//  ChangePWDViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 01/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class ChangePWDViewController: BaseViewController, customTextFieldProtocol, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var oldPwdErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var oldPwdErrorView: UIView!
    @IBOutlet weak var oldPwdErrorLbl: UILabel!
    
    @IBOutlet weak var newPwdErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var newPwdErrorView: UIView!
    @IBOutlet weak var newPwdErrorLbl: UILabel!
    
    @IBOutlet weak var confirmPwdErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var confirmPwdErrorView: UIView!
    @IBOutlet weak var confirmPwdErrorLbl: UILabel!

    @IBOutlet weak var saveBarBtnItm: UIBarButtonItem!
    @IBOutlet weak var confirmPasswordView: CustomTextFieldView!
    @IBOutlet weak var oldPasswordView: CustomTextFieldView!
    @IBOutlet weak var newPasswordView: CustomTextFieldView!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        oldPasswordView.customTextfieldDelegate = self
        oldPasswordView.textField.placeholder = "Old Password"
        oldPasswordView.floatingLbl.text = "Old Password"
        oldPasswordView.textField.isSecureTextEntry = true
        oldPasswordView.isPassowrdField = true
        oldPasswordView.textField.textColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1)
        oldPasswordView.addShowTextViewInPassword()
        
        newPasswordView.customTextfieldDelegate = self
        newPasswordView.textField.placeholder = "New Password"
        newPasswordView.floatingLbl.text = "New Password"
        newPasswordView.textField.isSecureTextEntry = true
        newPasswordView.isPassowrdField = true
        newPasswordView.textField.textColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1)
        newPasswordView.addShowTextViewInPassword()
        
        confirmPasswordView.customTextfieldDelegate = self
        confirmPasswordView.textField.placeholder = "Confirm New Password"
        confirmPasswordView.floatingLbl.text = "Confirm New Password"
        confirmPasswordView.textField.isSecureTextEntry = true
        confirmPasswordView.isPassowrdField = true
        confirmPasswordView.textField.textColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1)
        confirmPasswordView.addShowTextViewInPassword()
        hideAllErrorView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }

    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChangePWDViewController.actionOnTapGesture(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func actionOnTapGesture(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func actionOnSaveBtn(_ sender: UIBarButtonItem) {
        validateSaveBtnStatus()
    }
    
    public func actionOnSave() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view.window!)
            
            Utils.getUserPool().currentUser()?.changePassword(oldPasswordView.textField.text!, proposedPassword: newPasswordView.textField.text!).continue({ (task) -> Any? in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view.window!)
                    if task.error != nil {
                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                        let message = ((task.error as! NSError).userInfo["message"] as? String)!
                        print(message)
                        Utils.showAlert(title: "Error", message: message, viewController: self)
                    } else {
                        print("success")
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
                return nil
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    public func validateSaveBtnStatus() {
        
        if (oldPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: oldPasswordView, message: EMPTY_PASSWORD)
        } else if (oldPasswordView.textField.text!.characters.count < 8) {
            showErrorMsgView(customTextFieldview: oldPasswordView, message: PASSWORD_EIGHT_CHAR)
        } else if (newPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: newPasswordView, message: EMPTY_PASSWORD)
        } else if (newPasswordView.textField.text!.characters.count < 8) {
            showErrorMsgView(customTextFieldview: newPasswordView, message: PASSWORD_EIGHT_CHAR)
        } else if (confirmPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: confirmPasswordView, message: EMPTY_CONFIRM_PASSWORD)
        } else if (confirmPasswordView.textField.text! != newPasswordView.textField.text!) {
            showErrorMsgView(customTextFieldview: confirmPasswordView, message: PASSWORD_NOT_MATCH)
        } else {
            oldPasswordView.textField.resignFirstResponder()
            newPasswordView.textField.resignFirstResponder()
            confirmPasswordView.textField.resignFirstResponder()

            actionOnSave()
        }

    }
    
    private func updateTFIndicator() {
        if (oldPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (oldPasswordView.textField.text!.characters.count < 8) {
            oldPasswordView.hidePositiveIndicator()
        } else {
            oldPasswordView.showPositiveIndicator()
        }
        
        if (newPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (newPasswordView.textField.text!.characters.count < 8) {
            newPasswordView.hidePositiveIndicator()
        } else {
            newPasswordView.showPositiveIndicator()
        }
        
        if (confirmPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (confirmPasswordView.textField.text!.characters.count < 8) || (confirmPasswordView.textField.text! != newPasswordView.textField.text!) {
            confirmPasswordView.hidePositiveIndicator()
        } else {
            confirmPasswordView.showPositiveIndicator()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        
        if oldPasswordView.textField == textField {
            oldPasswordView.placeHolderText = "Old Password"
            oldPasswordView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: oldPasswordView)
            oldPasswordView.addSelectedConfig()
        } else if newPasswordView.textField == textField {
            newPasswordView.placeHolderText = "New Password"
            newPasswordView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: newPasswordView)
            newPasswordView.addSelectedConfig()
        } else {
            confirmPasswordView.placeHolderText = "Confirm New Password"
            confirmPasswordView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: confirmPasswordView)
            confirmPasswordView.addSelectedConfig()
        }
        
        self.offSetForKeyboard = 20.0
        self.activeField = textField
    }
    
    func endTextFieldEditing(textField: UITextField) {
        updateTFIndicator()
        if self.activeField == oldPasswordView.textField {
            
            if (oldPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: oldPasswordView, message: EMPTY_PASSWORD)
            } else if (oldPasswordView.textField.text!.characters.count < 8) {
                showErrorMsgView(customTextFieldview: oldPasswordView, message: PASSWORD_EIGHT_CHAR)
            }
        } else if self.activeField == newPasswordView.textField {
            
            if (newPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: newPasswordView, message: EMPTY_PASSWORD)
            } else if (newPasswordView.textField.text!.characters.count < 8) {
                showErrorMsgView(customTextFieldview: newPasswordView, message: PASSWORD_EIGHT_CHAR)
            }
        } else if self.activeField == confirmPasswordView.textField {
            if (confirmPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: confirmPasswordView, message: EMPTY_CONFIRM_PASSWORD)
            } else if (confirmPasswordView.textField.text! != newPasswordView.textField.text!) {
                showErrorMsgView(customTextFieldview: confirmPasswordView, message: PASSWORD_NOT_MATCH)
            }
        }
    }
    
    func shouldReturnTextField(textField: UITextField) {
        moveToNextTextField()
    }
    
    func moveToNextTextField() {
        if !(oldPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            (oldPasswordView.textField.text!.characters.count >= 8) &&
            !(newPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            (newPasswordView.textField.text!.characters.count >= 8) &&
            !(confirmPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            (confirmPasswordView.textField.text!.characters.count >= 8) &&
            (confirmPasswordView.textField.text! == newPasswordView.textField.text!) {
            
            validateSaveBtnStatus()
        } else {
            if self.activeField == oldPasswordView.textField {
                if (oldPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: oldPasswordView, message: EMPTY_PASSWORD)
                } else if (oldPasswordView.textField.text!.characters.count < 8) {
                    showErrorMsgView(customTextFieldview: oldPasswordView, message: PASSWORD_EIGHT_CHAR)
                } else {
                    newPasswordView.textField.becomeFirstResponder()
                }
            } else if self.activeField == newPasswordView.textField {
                if (newPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: newPasswordView, message: EMPTY_PASSWORD)
                } else if (newPasswordView.textField.text!.characters.count < 8) {
                    showErrorMsgView(customTextFieldview: newPasswordView, message: PASSWORD_EIGHT_CHAR)
                } else {
                    confirmPasswordView.textField.becomeFirstResponder()
                }
            } else if self.activeField == confirmPasswordView.textField {
                if (confirmPasswordView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: confirmPasswordView, message: EMPTY_CONFIRM_PASSWORD)
                } else if (confirmPasswordView.textField.text! != newPasswordView.textField.text!) {
                    showErrorMsgView(customTextFieldview: confirmPasswordView, message: PASSWORD_NOT_MATCH)
                } else {
                }
            }
        }
    }

    
    func editingChangedTextField(textField: UITextField) {
        if textField == oldPasswordView.textField {
            hideErrorMsgView(customTextFieldview: oldPasswordView)
            oldPasswordView.addSelectedConfig()
        } else if textField == newPasswordView.textField {
            hideErrorMsgView(customTextFieldview: newPasswordView)
            newPasswordView.addSelectedConfig()
        } else if textField == confirmPasswordView.textField {
            hideErrorMsgView(customTextFieldview: confirmPasswordView)
            confirmPasswordView.addSelectedConfig()
        }

    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    func hideAllErrorView() {
        hideErrorMsgView(customTextFieldview: oldPasswordView)
        hideErrorMsgView(customTextFieldview: newPasswordView)
        hideErrorMsgView(customTextFieldview: confirmPasswordView)
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == oldPasswordView {
            oldPwdErrorView.isHidden = true
            oldPwdErrorHCons.constant = 0
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
        } else if customTextFieldview == newPasswordView {
            newPwdErrorView.isHidden = true
            newPwdErrorHCons.constant = 0
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
        } else if customTextFieldview == confirmPasswordView {
            confirmPwdErrorView.isHidden = true
            confirmPwdErrorHCons.constant = 0
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
        }
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == oldPasswordView {
            oldPwdErrorView.isHidden = false
            oldPwdErrorHCons.constant = 40
            oldPwdErrorLbl.text = message
            oldPasswordView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == newPasswordView {
            newPwdErrorView.isHidden = false
            newPwdErrorHCons.constant = 40
            newPwdErrorLbl.text = message
            newPasswordView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == confirmPasswordView {
            confirmPwdErrorView.isHidden = false
            confirmPwdErrorHCons.constant = 40
            confirmPwdErrorLbl.text = message
            confirmPasswordView.errorConfiguration()
            adjustLayouts()
        }
    }
}
