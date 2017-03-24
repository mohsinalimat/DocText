//
//  SignUpPhNoViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 10/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class SignUpPhNoViewController: BaseViewController, customTextFieldProtocol, baseViewControllerProtocolDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- IBOutlets
    @IBOutlet weak var phNoErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var phNoErrorView: UIView!
    @IBOutlet weak var phNoErrorLbl: UILabel!
    
    @IBOutlet weak var checkBoxErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var checkBoxErrorView: UIView!
    @IBOutlet weak var checkBoxErrorLbl: UILabel!

    @IBOutlet weak var phoneNoView: CustomTextFieldView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!

    // MARK:- UIViewContoller
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        
        phoneNoView.customTextfieldDelegate = self
        phoneNoView.textField.placeholder = "Phone number"
        phoneNoView.textField.keyboardType = .numberPad
        phoneNoView.floatingLbl.text = "Phone number"
        phoneNoView.textField.keyboardAppearance = .default
        Utils.disableCheckBox(checkBoxBtn: checkBoxBtn)
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 4)
        hideAllErrorView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardDelegate = self
        progressView.progress = 0.0
        if !Utils.signupObj.phoneNumber.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            phoneNoView.textField.text! = Utils.formatToPhoneNumber(mobileNumber: Utils.signupObj.phoneNumber)
            phoneNoView.showPositiveIndicator()
            phoneNoView.showTextFieldWithText()
        } else {
            phoneNoView.hidePositiveIndicator()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressView.setProgress(Utils.signupObj.userRole == "Patient" ? Utils.getProgressPercentage(totoalVal: 5, currentVal: 3) : Utils.getProgressPercentage(totoalVal: 7, currentVal: 5), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        phoneNoView.textField.resignFirstResponder()
    }
    
    // MARK:- IBAction
    @IBAction func actionOnCheckBox(_ sender: UIButton) {
        phoneNoView.textField.resignFirstResponder()
        hideErrorMsgView(customTextFieldview: CustomTextFieldView())
        if checkBoxBtn.tag == 1 {
            Utils.disableCheckBox(checkBoxBtn: checkBoxBtn)
        } else {
            Utils.enableCheckBox(checkBoxBtn: checkBoxBtn)
        }
    }
    
    @IBAction func actionOnTermOfService(_ sender: UIButton) {
        if let url = URL(string: "https://www.google.com") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
            }
        }
    }
    
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        phoneNoView.textField.resignFirstResponder()
        validateNextBtnStatus()
    }
    
    func register() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            phoneNoView.textField.resignFirstResponder()
            if Utils.signupObj.userRole == "Doctor" {
                self.setDoctorParams()
            } else {
                self.setPatientParams()
            }
            
            Utils.showHUD(view: self.view)
            let phoneAttribute = AWSCognitoIdentityUserAttributeType()
            phoneAttribute?.name  = "phone_number"
            phoneAttribute?.value = "\(Utils.getPhoneNoCountryCode())\(Utils.signupObj.phoneNumber)"
            
            let emailAttribute = AWSCognitoIdentityUserAttributeType()
            emailAttribute?.name  = "email"
            emailAttribute?.value = Utils.signupObj.emailID
            
            let user = User()
            user.emailID = Utils.signupObj.emailID
            Utils.setCurrentUser(currentUser: user)
            
            let dobAttribute = AWSCognitoIdentityUserAttributeType()
            dobAttribute?.name  = "birthdate"
            dobAttribute?.value = Utils.signupObj.dateOfBirth
            
            let firstNameAttribute = AWSCognitoIdentityUserAttributeType()
            firstNameAttribute?.name  = "custom:FirstName"
            firstNameAttribute?.value = Utils.signupObj.firstName
            
            let lastNameAttribute = AWSCognitoIdentityUserAttributeType()
            lastNameAttribute?.name  = "custom:LastName"
            lastNameAttribute?.value = Utils.signupObj.lastName
            
            let userRoleAttribute = AWSCognitoIdentityUserAttributeType()
            userRoleAttribute?.name  = "custom:UserRole"
            userRoleAttribute?.value = Utils.signupObj.userRole
            
            let doctorTitleAttribute = AWSCognitoIdentityUserAttributeType()
            doctorTitleAttribute?.name  = "custom:doctorTitle"
            doctorTitleAttribute?.value = Utils.signupObj.doctorTitle
            
            let doctorTypeAttribute = AWSCognitoIdentityUserAttributeType()
            doctorTypeAttribute?.name  = "custom:doctorType"
            doctorTypeAttribute?.value = Utils.signupObj.doctorType
            
            let streetAttribute = AWSCognitoIdentityUserAttributeType()
            streetAttribute?.name  = "custom:doctor_addr_street"
            streetAttribute?.value = Utils.signupObj.doctor_addr_street
            
            let unitAttribute = AWSCognitoIdentityUserAttributeType()
            unitAttribute?.name  = "custom:doctor_addr_unit"
            unitAttribute?.value = Utils.signupObj.doctor_addr_unit.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty ? "nil" : Utils.signupObj.doctor_addr_unit
            
            let cityAttribute = AWSCognitoIdentityUserAttributeType()
            cityAttribute?.name  = "custom:doctor_addr_city"
            cityAttribute?.value = Utils.signupObj.doctor_addr_city
            
            let stateAttribute = AWSCognitoIdentityUserAttributeType()
            stateAttribute?.name  = "custom:doctor_addr_state"
            stateAttribute?.value = Utils.signupObj.doctor_addr_state
            
            let zipAttribute = AWSCognitoIdentityUserAttributeType()
            zipAttribute?.name  = "custom:doctor_addr_zip"
            zipAttribute?.value = Utils.signupObj.doctor_addr_zip
            
            let officePhnoAttribute = AWSCognitoIdentityUserAttributeType()
            officePhnoAttribute?.name  = "custom:doctor_office_phno"
            officePhnoAttribute?.value = Utils.signupObj.doctor_office_phNo
            
            let profilePicAttribute = AWSCognitoIdentityUserAttributeType()
            profilePicAttribute?.name  = "custom:profilePictureUrl"
            profilePicAttribute?.value = "nil"

            let ph_country_code_Attribute = AWSCognitoIdentityUserAttributeType()
            ph_country_code_Attribute?.name  = "custom:Ph_Country_code"
            ph_country_code_Attribute?.value = Utils.getPhoneNoCountryCode()

            let customerIdAttribute = AWSCognitoIdentityUserAttributeType()
            customerIdAttribute?.name  = "custom:CustomerId"
            customerIdAttribute?.value = Utils.signupObj.customer_Id
            
            let cardIdAttribute = AWSCognitoIdentityUserAttributeType()
            cardIdAttribute?.name  = "custom:CardId"
            cardIdAttribute?.value = Utils.signupObj.card_Id
            
            let doctorChargeAttribute = AWSCognitoIdentityUserAttributeType()
            doctorChargeAttribute?.name  = "custom:doctor_charge"
            doctorChargeAttribute?.value = Utils.signupObj.doctor_charge

            let params = [phoneAttribute!, emailAttribute!, dobAttribute!, firstNameAttribute!, lastNameAttribute!, userRoleAttribute!, doctorTitleAttribute!, doctorTypeAttribute!, streetAttribute!, unitAttribute!, cityAttribute!, stateAttribute!, zipAttribute!, profilePicAttribute!, customerIdAttribute!, cardIdAttribute!, officePhnoAttribute!, doctorChargeAttribute!, ph_country_code_Attribute!]
            
            Utils.getUserPool().signUp(Utils.signupObj.emailID, password: Utils.signupObj.password, userAttributes: params, validationData: nil).continue({ (task) -> Any? in
                
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if task.error != nil {
                        
                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                        print(((task.error as! NSError).userInfo["message"] as? String)!)
                        Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                    } else {
                        let response: AWSCognitoIdentityUserPoolSignUpResponse = task.result!
                        print(response.user)
                        print((Utils.getUserPool().currentUser()?.isSignedIn)!)

                        print(response.user.isSignedIn)
                        if (response.userConfirmed?.intValue != AWSCognitoIdentityUserStatus.confirmed.rawValue) {
                            let confirmationCodeVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ConfirmationViewController") as! ConfirmationViewController
                            confirmationCodeVC.identityUser = response.user
                            self.navigationController?.pushViewController(confirmationCodeVC, animated: true)
                        } else {
                            print("User confirmed...")
                        }
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

    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        phoneNoView.placeHolderText = "Phone number"
        phoneNoView.hidePositiveIndicator()
        hideErrorMsgView(customTextFieldview: phoneNoView)

        self.offSetForKeyboard = 20.0
        self.activeField = textField
    }
    
    func endTextFieldEditing(textField: UITextField) {
        updateTFIndicator()
    }
    
    func shouldReturnTextField(textField: UITextField) {
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    func editingChangedTextField(textField: UITextField) {
        hideErrorMsgView(customTextFieldview: phoneNoView)
        phoneNoView.addSelectedConfig()
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        let length = Utils.getLength(mobileNumber: textField.text!)
        if(length == 10) {
            if(range.length == 0) {
                return false
            }
        }
        
        if(length == 3) {
            let num = Utils.formatNumber(mobileNumber: textField.text!)
            textField.text = "(\(num)) "
            if(range.length > 0) {
                let index = num.index(num.startIndex, offsetBy: 3)
                textField.text = "\(num.substring(to: index))"
            }
        } else if(length == 6) {
            let num = Utils.formatNumber(mobileNumber: textField.text!)
            let toIndex = num.index(num.startIndex, offsetBy: 3)
            textField.text = "(\(num.substring(to: toIndex))) \(num.substring(from: toIndex))-"
            if(range.length > 0) {
                textField.text = "(\(num.substring(to: toIndex))) \(num.substring(from: toIndex))"
            }
        }
        return true
    }
    
    // MARK:- Other Methods
    func validateNextBtnStatus() {
        if (Utils.formatNumber(mobileNumber: phoneNoView.textField.text!).characters.count != 10) {
            showErrorMsgView(customTextFieldview: phoneNoView, message: PHNO_10_CHAR)
        } else if (checkBoxBtn.tag != 0 ? false : true) {
            showErrorMsgView(customTextFieldview: CustomTextFieldView(), message: CHECK_TICK_MARK)
        } else {
            Utils.signupObj.phoneNumber = Utils.formatNumber(mobileNumber: phoneNoView.textField.text!)
            register()
        }
    }
    
    private func updateTFIndicator() {
        if (phoneNoView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (Utils.formatNumber(mobileNumber: phoneNoView.textField.text!).characters.count != 10) {
            phoneNoView.hidePositiveIndicator()
        } else {
            phoneNoView.showPositiveIndicator()
        }
    }
    
    func setDoctorParams() {
        Utils.signupObj.dateOfBirth = "mm/dd/yyyy"
        Utils.signupObj.customer_Id = "nil"
        Utils.signupObj.card_Id = "nil"
        Utils.signupObj.doctor_charge = "nil"
    }
    
    func setPatientParams() {
        Utils.signupObj.doctorTitle = "nil"
        Utils.signupObj.doctorType = "nil"
        Utils.signupObj.doctor_addr_street = "nil"
        Utils.signupObj.doctor_addr_unit = "nil"
        Utils.signupObj.doctor_addr_city = "nil"
        Utils.signupObj.doctor_addr_state = "nil"
        Utils.signupObj.doctor_addr_zip = "nil"
        Utils.signupObj.doctor_office_phNo = "nil"
        Utils.signupObj.customer_Id = "nil"
        Utils.signupObj.card_Id = "nil"
        Utils.signupObj.doctor_charge = "nil"
    }
    
    
    func keyboardSize(size: CGSize) {
        self.nextBtnBCons.constant = size.height
        UIView.animate(withDuration: 0.50, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == phoneNoView {
            phNoErrorView.isHidden = false
            phNoErrorHCons.constant = 40
            phNoErrorLbl.text = message
            phoneNoView.errorConfiguration()
            adjustLayouts()
        } else {
            checkBoxErrorView.isHidden = false
            checkBoxErrorHCons.constant = 40
            checkBoxErrorLbl.text = message
            adjustLayouts()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == phoneNoView {
            phNoErrorView.isHidden = true
            phNoErrorHCons.constant = 0
            adjustLayouts()
        } else {
            checkBoxErrorView.isHidden = true
            checkBoxErrorHCons.constant = 0
            adjustLayouts()
        }
    }
    
    func hideAllErrorView() {
        hideErrorMsgView(customTextFieldview: phoneNoView)
        hideErrorMsgView(customTextFieldview: CustomTextFieldView())
    }
}
