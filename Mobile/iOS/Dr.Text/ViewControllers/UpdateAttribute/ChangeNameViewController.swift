//
//  ChangeNameViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 09/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
//import AWSLambda

class ChangeNameViewController: UIViewController, customTextFieldProtocol, UIGestureRecognizerDelegate {
    
    // MARK:- IBOutlets
    @IBOutlet weak var firstNameErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var firstNameErrorView: UIView!
    @IBOutlet weak var firstNameErrorLbl: UILabel!
    
    @IBOutlet weak var lastNameErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var lastNameErrorView: UIView!
    @IBOutlet weak var lastNameErrorLbl: UILabel!
    
    @IBOutlet weak var saveBarBtnItm: UIBarButtonItem!
    @IBOutlet weak var firstNameTextFieldView: CustomTextFieldView!
    @IBOutlet weak var lastNameTextFieldView: CustomTextFieldView!
    
    // MARK:- UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        firstNameTextFieldView.customTextfieldDelegate = self
        firstNameTextFieldView.textField.placeholder = "First name"
        firstNameTextFieldView.floatingLbl.text = "First name"
        firstNameTextFieldView.textField.text = Utils.user.firstName!
        firstNameTextFieldView.showTextFieldWithText()
        lastNameTextFieldView.customTextfieldDelegate = self
        lastNameTextFieldView.textField.placeholder = "Last name"
        lastNameTextFieldView.floatingLbl.text = "Last name"
        lastNameTextFieldView.textField.text = Utils.user.lastName!
        lastNameTextFieldView.showTextFieldWithText()
        hideErrorMsgView(customTextFieldview: firstNameTextFieldView)
        hideErrorMsgView(customTextFieldview: lastNameTextFieldView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        firstNameTextFieldView.textField.resignFirstResponder()
        lastNameTextFieldView.textField.resignFirstResponder()
    }
    
    // MARK:- IBAction
    @IBAction func actionOnSaveBtn(_ sender: UIButton) {
        validateSaveBtnStatus()
    }
    
    // MARK:- Other Methods
    func setBackButton() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackChevron") , style: .plain, target: self, action: #selector(BaseViewController.actionOnBackBtn(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    
    func actionOnBackBtn(sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
    
    public func validateSaveBtnStatus() {

        
        
        if (firstNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: firstNameTextFieldView, message: EMPTY_FIRST_NAME)
        } else if !Utils.isStringContainsNumbersSymbols(text: firstNameTextFieldView.textField.text!) {
            showErrorMsgView(customTextFieldview: firstNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
        } else if (lastNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: lastNameTextFieldView, message: EMPTY_LAST_NAME)
        } else if !Utils.isStringContainsNumbersSymbols(text: lastNameTextFieldView.textField.text!) {
            showErrorMsgView(customTextFieldview: lastNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
        } else {
            Utils.signupObj.firstName = firstNameTextFieldView.textField.text!
            Utils.signupObj.lastName  = lastNameTextFieldView.textField.text!
            saveAction()
        }
        
    }
    
    private func updateTFIndicator() {
        if (firstNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            firstNameTextFieldView.hidePositiveIndicator()
        } else {
            firstNameTextFieldView.showPositiveIndicator()
        }
        
        if (lastNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || !Utils.isStringContainsNumbersSymbols(text: lastNameTextFieldView.textField.text!) {
            lastNameTextFieldView.hidePositiveIndicator()
        } else {
            lastNameTextFieldView.showPositiveIndicator()
        }
    }
    
    func updateUserDetails() {
        let user = Utils.user!
        user.firstName = firstNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        user.lastName = lastNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        Utils.updateUserDetails(user: user, viewController: self)
    }
    
    
    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChangePWDViewController.actionOnTapGesture(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func actionOnTapGesture(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        if firstNameTextFieldView.textField == textField {
            firstNameTextFieldView.placeHolderText = "First name"
            firstNameTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: firstNameTextFieldView)
        } else {
            lastNameTextFieldView.placeHolderText = "Last name"
            lastNameTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: lastNameTextFieldView)
        }
    }
    
    func endTextFieldEditing(textField: UITextField) {
        updateTFIndicator()
        if textField == firstNameTextFieldView.textField {
            if (firstNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: firstNameTextFieldView, message: EMPTY_FIRST_NAME)
            } else if !Utils.isStringContainsNumbersSymbols(text: firstNameTextFieldView.textField.text!) {
                showErrorMsgView(customTextFieldview: firstNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
            }
        } else {
            if (lastNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: lastNameTextFieldView, message: EMPTY_LAST_NAME)
            } else if !Utils.isStringContainsNumbersSymbols(text: lastNameTextFieldView.textField.text!) {
                showErrorMsgView(customTextFieldview: lastNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
            }
        }
        
    }
    
    func shouldReturnTextField(textField: UITextField) {
        if textField == firstNameTextFieldView.textField {
            if (firstNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: firstNameTextFieldView, message: EMPTY_FIRST_NAME)
            } else if !Utils.isStringContainsNumbersSymbols(text: firstNameTextFieldView.textField.text!) {
                showErrorMsgView(customTextFieldview: firstNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
            } else {
                lastNameTextFieldView.textField.becomeFirstResponder()
            }
        } else {
            if (lastNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: lastNameTextFieldView, message: EMPTY_LAST_NAME)
            } else if !Utils.isStringContainsNumbersSymbols(text: lastNameTextFieldView.textField.text!) {
                showErrorMsgView(customTextFieldview: lastNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
            }
        }
    }
    
   
    
    func editingChangedTextField(textField: UITextField) {
        //        validateSaveBtnStatus()
        if textField == firstNameTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: firstNameTextFieldView)
            firstNameTextFieldView.addSelectedConfig()
        } else {
            hideErrorMsgView(customTextFieldview: lastNameTextFieldView)
            lastNameTextFieldView.addSelectedConfig()
        }
        
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    
    func saveAction() {
        firstNameTextFieldView.textField.resignFirstResponder()
        lastNameTextFieldView.textField.resignFirstResponder()
        
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view.window!)
            
            let firstNameAttribute = AWSCognitoIdentityUserAttributeType()
            firstNameAttribute?.name  = "custom:FirstName"
            firstNameAttribute?.value = firstNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            let lastNameAttribute = AWSCognitoIdentityUserAttributeType()
            lastNameAttribute?.name  = "custom:LastName"
            lastNameAttribute?.value = lastNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            Utils.getUserPool().currentUser()?.update([firstNameAttribute!, lastNameAttribute!]).continue({ (task) -> Any? in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view.window!)
                    if task.error != nil {
                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                        print(((task.error as! NSError).userInfo["message"] as? String)!)
                        Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                    } else {
                        print("success")
                        self.updateUserDetails()
                    }
                }
                return nil
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == firstNameTextFieldView {
            firstNameErrorView.isHidden = false
            firstNameErrorHCons.constant = 40
            firstNameErrorLbl.text = message
            firstNameTextFieldView.errorConfiguration()
            adjustLayouts()
        } else {
            lastNameErrorView.isHidden = false
            lastNameErrorHCons.constant = 40
            lastNameErrorLbl.text = message
            lastNameTextFieldView.errorConfiguration()
            adjustLayouts()
        }
    }
    
    func adjustLayouts() {
        view.layoutIfNeeded()
        view.setNeedsLayout()
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == firstNameTextFieldView {
            firstNameErrorView.isHidden = true
            firstNameErrorHCons.constant = 0
            adjustLayouts()
        } else {
            lastNameErrorView.isHidden = true
            lastNameErrorHCons.constant = 0
            adjustLayouts()
        }
    }
}
