//
//  RequestNewPWDViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 01/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class RequestNewPWDViewController: BaseViewController, customTextFieldProtocol, baseViewControllerProtocolDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var emailTextFieldView: CustomTextFieldView!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var emailErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var emailErrorLbl: UILabel!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setTapGesture()
        setBackButton()
        emailTextFieldView.customTextfieldDelegate = self
        emailTextFieldView.textField.placeholder = "Email"
        emailTextFieldView.floatingLbl.text = "Email"
        emailTextFieldView.textField.keyboardType = .emailAddress
        emailTextFieldView.textField.autocapitalizationType = .none
        hideAllErrorView()
        self.activeField = emailTextFieldView.textField
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardDelegate = self
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

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        emailTextFieldView.textField.resignFirstResponder()
    }
    
    // MARK:- IBAction
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        moveToNextTextField()
    }
    
    // MARK:- Other Methods
    public func validateNextBtnStatus() {
        
        if (emailTextFieldView.textField.text?.isEmpty)! {
            showErrorMsgView(customTextFieldview: emailTextFieldView, message: EMPTY_EMAIL_ID)
        } else if !Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) {
            showErrorMsgView(customTextFieldview: emailTextFieldView, message: VALID_EMAIL_ID)
        } else {
            Utils.signupObj.emailID = emailTextFieldView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            emailTextFieldView.textField.resignFirstResponder()
            let user = Utils.getUserPool().getUser(emailTextFieldView.textField.text!)
            print(user.username!)
            
            if Utils.reachability.currentReachabilityStatus != .notReachable {
                Utils.showHUD(view: self.view)
                user.forgotPassword().continue({ (task) -> Any? in
                    DispatchQueue.main.async {
                        Utils.hideHUD(view: self.view)
                        if task.error != nil {
                            print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                            print(((task.error as! NSError).userInfo["message"] as? String)!)
                            Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                        } else {
                            print("verification code for forgot password sent successfully")
                            let recoveryCodeVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "RecoveryCodeViewController") as! RecoveryCodeViewController
                            recoveryCodeVC.emailID = self.emailTextFieldView.textField.text!
                            self.navigationController?.pushViewController(recoveryCodeVC, animated: true)
                        }
                    }
                    return nil
                })
            } else {
                Utils.showAlertForInternetNotReachable(viewController: self)
            }
        }
    }
    
    private func updateTFIndicator() {
        if (emailTextFieldView.textField.text?.isEmpty)! || !Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) {
            emailTextFieldView.hidePositiveIndicator()
        } else {
            emailTextFieldView.showPositiveIndicator()
        }
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        self.offSetForKeyboard = 20.0
        
        emailTextFieldView.placeHolderText = "Email"
        emailTextFieldView.hidePositiveIndicator()
        hideErrorMsgView(customTextFieldview: emailTextFieldView)

    }
    
    func endTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        updateTFIndicator()
    }
    
    func shouldReturnTextField(textField: UITextField) {
        moveToNextTextField()
    }
    
    func moveToNextTextField() {
        if !(emailTextFieldView.textField.text?.isEmpty)! &&
            Utils.isValidEmail(emailId: emailTextFieldView.textField.text!)  {
            validateNextBtnStatus()
        } else {
            if self.activeField == emailTextFieldView.textField {
                if (emailTextFieldView.textField.text?.isEmpty)! {
                    showErrorMsgView(customTextFieldview: emailTextFieldView, message: EMPTY_EMAIL_ID)
                } else if !Utils.isValidEmail(emailId: emailTextFieldView.textField.text!) {
                    showErrorMsgView(customTextFieldview: emailTextFieldView, message: VALID_EMAIL_ID)
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
        }
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == emailTextFieldView {
            emailErrorView.isHidden = false
            emailErrorHCons.constant = 40
            emailErrorLbl.text = message
            emailTextFieldView.errorConfiguration()
            adjustLayouts()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == emailTextFieldView {
            emailErrorView.isHidden = true
            emailErrorHCons.constant = 0
            adjustLayouts()
        }
    }
    
    func hideAllErrorView() {
        hideErrorMsgView(customTextFieldview: emailTextFieldView)
    }
    
    func keyboardSize(size: CGSize) {
        self.nextBtnBCons.constant = size.height
        UIView.animate(withDuration: 0.50, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
}
