//
//  SignUpViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 10/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

struct signUp {
    var firstName   = String()
    var lastName    = String()
    var emailID     = String()
    var password    = String()
    var confirmPWD  = String()
    var phoneNumber = String()
    var phNoCountryCode = String()
    var userRole    = String()
    var doctorCode  = String()
    var dateOfBirth  = String()
    var doctorTitle  = String()
    var doctorType  = String()
    var doctor_charge  = String()
    var doctor_addr_street  = String()
    var doctor_addr_unit  = String()
    var doctor_addr_city  = String()
    var doctor_addr_state  = String()
    var doctor_addr_zip  = String()
    var doctor_office_phNo = String()
    var customer_Id = String()
    var card_Id     = String()
}

class SignUpViewController: BaseViewController, customTextFieldProtocol, baseViewControllerProtocolDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- IBOutlets
    @IBOutlet weak var firstNameErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var lastNameErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var firstNameErrorView: UIView!
    @IBOutlet weak var firstNameErrorLbl: UILabel!
    @IBOutlet weak var lastNameErrorView: UIView!
    @IBOutlet weak var lastNameErrorLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var firstNameTextFieldView: CustomTextFieldView!
    @IBOutlet weak var lastNameTextFieldView: CustomTextFieldView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    
    // MARK:- UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        firstNameTextFieldView.customTextfieldDelegate = self
        firstNameTextFieldView.textField.placeholder = "First name"
        firstNameTextFieldView.floatingLbl.text = "First name"
        
        lastNameTextFieldView.customTextfieldDelegate = self
        lastNameTextFieldView.textField.placeholder = "Last name"
        lastNameTextFieldView.floatingLbl.text = "Last name"
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 4)
        hideErrorMsgView(customTextFieldview: firstNameTextFieldView)
        hideErrorMsgView(customTextFieldview: lastNameTextFieldView)
        self.activeField = firstNameTextFieldView.textField
    }
    
    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChangePWDViewController.actionOnTapGesture(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func actionOnTapGesture(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressView.progress = 0.0
        self.keyboardDelegate = self
        if !Utils.signupObj.firstName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            firstNameTextFieldView.textField.text! = Utils.signupObj.firstName
            firstNameTextFieldView.showPositiveIndicator()
            firstNameTextFieldView.showTextFieldWithText()
        } else {
            firstNameTextFieldView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.lastName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            lastNameTextFieldView.textField.text!  = Utils.signupObj.lastName
            lastNameTextFieldView.showPositiveIndicator()
            lastNameTextFieldView.showTextFieldWithText()
        } else {
            lastNameTextFieldView.hidePositiveIndicator()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressView.setProgress(Utils.signupObj.userRole == "Patient" ? Utils.getProgressPercentage(totoalVal: 5, currentVal: 1) : Utils.getProgressPercentage(totoalVal: 7, currentVal: 1), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        firstNameTextFieldView.textField.resignFirstResponder()
        lastNameTextFieldView.textField.resignFirstResponder()
    }
    
    // MARK:- IBAction
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        moveToNextTextField()
    }
    
    // MARK:- Other Methods
    private func goToSignUpEmailVC() {
        firstNameTextFieldView.textField.resignFirstResponder()
        lastNameTextFieldView.textField.resignFirstResponder()
        
        if Utils.signupObj.userRole == "Patient" {
            let signUpEPDVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "SignupEmailPwdDobViewController") as! SignupEmailPwdDobViewController
            self.navigationController?.pushViewController(signUpEPDVC, animated: true)
        } else {
            let signUpEPDVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorPromptViewController") as! DoctorPromptViewController
            self.navigationController?.pushViewController(signUpEPDVC, animated: true)
        }
    }
    
    public func validateNextBtnStatus() {
        
        if (firstNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: firstNameTextFieldView, message: EMPTY_FIRST_NAME)
        } else if !Utils.isStringContainsNumbersSymbols(text: firstNameTextFieldView.textField.text!) {
            showErrorMsgView(customTextFieldview: firstNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
        } else if (lastNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: lastNameTextFieldView, message: EMPTY_LAST_NAME)
        } else if !Utils.isStringContainsNumbersSymbols(text: lastNameTextFieldView.textField.text!) {
            showErrorMsgView(customTextFieldview: lastNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
        } else {
            Utils.signupObj.firstName = firstNameTextFieldView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            Utils.signupObj.lastName  = lastNameTextFieldView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            goToSignUpEmailVC()
        }
    }
    
    private func updateTFIndicator() {
        if (firstNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || !Utils.isStringContainsNumbersSymbols(text: firstNameTextFieldView.textField.text!) {
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
        self.offSetForKeyboard = 20.0
        self.activeField = textField
    }
    
    func endTextFieldEditing(textField: UITextField) {
        updateTFIndicator()
        if self.activeField == firstNameTextFieldView.textField {
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
        moveToNextTextField()
    }
    
    func editingChangedTextField(textField: UITextField) {
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
    
    func moveToNextTextField() {
        
        if !(firstNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            Utils.isStringContainsNumbersSymbols(text: firstNameTextFieldView.textField.text!) &&
            !(lastNameTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            Utils.isStringContainsNumbersSymbols(text: lastNameTextFieldView.textField.text!) {
            validateNextBtnStatus()
        } else {
            
            if self.activeField == firstNameTextFieldView.textField {
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
                } else {
                    validateNextBtnStatus()
                }
            }
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
    
    private func updateErrorMsgView(textField: UITextField) {
        if firstNameTextFieldView.textField == textField {
            if !Utils.isStringContainsNumbersSymbols(text: textField.text!) {
                showErrorMsgView(customTextFieldview: firstNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
            } else {
                hideErrorMsgView(customTextFieldview: firstNameTextFieldView)
            }
        } else {
            if !Utils.isStringContainsNumbersSymbols(text: textField.text!) {
                showErrorMsgView(customTextFieldview: lastNameTextFieldView, message: NUMBERS_SYMBOLS_NOT_SUPPORTED)
            } else {
                hideErrorMsgView(customTextFieldview: lastNameTextFieldView)
            }
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
