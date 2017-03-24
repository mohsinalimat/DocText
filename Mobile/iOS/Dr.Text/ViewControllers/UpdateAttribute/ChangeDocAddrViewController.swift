//
//  ChangeDocAddrViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 09/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ChangeDocAddrViewController: BaseViewController, customTextFieldProtocol, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var streetView: CustomTextFieldView!
    @IBOutlet weak var unitView: CustomTextFieldView!
    @IBOutlet weak var cityView: CustomTextFieldView!
    @IBOutlet weak var stateView: CustomTextFieldView!
    @IBOutlet weak var zipView: CustomTextFieldView!
    @IBOutlet weak var phoneNoView: CustomTextFieldView!
    @IBOutlet weak var saveBarBtnItm: UIBarButtonItem!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    var stateList = [String]()
    var statesDict: Dictionary<String, String>?
    var picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        getStates()
        streetView.customTextfieldDelegate = self
        streetView.textField.placeholder = "Street and number, P.O. Box, etc"
        streetView.floatingLbl.text = "Street and number, P.O. Box, etc"
        streetView.textField.text = Utils.user.doctor_addr_street!
        streetView.showTextFieldWithText()
        
        unitView.customTextfieldDelegate = self
        unitView.textField.placeholder = "Suite, Unit, Building, etc."
        unitView.floatingLbl.text = "Suite, Unit, Building, etc."
        if Utils.user.doctor_addr_unit! != "nil" {
            unitView.textField.text = Utils.user.doctor_addr_unit!
            unitView.showTextFieldWithText()
        }
        
        cityView.customTextfieldDelegate = self
        cityView.textField.placeholder = "City"
        cityView.floatingLbl.text = "City"
        cityView.textField.text = Utils.user.doctor_addr_city!
        cityView.showTextFieldWithText()
        
        stateView.customTextfieldDelegate = self
        stateView.textField.placeholder = "State"
        stateView.floatingLbl.text = "State"
        stateView.textField.text = Utils.user.doctor_addr_state!
        stateView.showTextFieldWithText()
        
        zipView.customTextfieldDelegate = self
        zipView.textField.placeholder = "Zip"
        zipView.floatingLbl.text = "Zip"
        zipView.textField.keyboardType = .numberPad
        zipView.textField.keyboardAppearance = .default
        zipView.textField.text = Utils.user.doctor_addr_zip!
        zipView.showTextFieldWithText()
        
        phoneNoView.customTextfieldDelegate = self
        phoneNoView.textField.placeholder = "Office Phone Number"
        phoneNoView.textField.keyboardType = .phonePad
        phoneNoView.textField.keyboardAppearance = .default
        phoneNoView.floatingLbl.text = "Office Phone Number"
        let phno = Utils.user.doctor_office_phno!.replacingOccurrences(of: Utils.user.phCountryCode!, with: "")
        phoneNoView.textField.text =  Utils.formatToPhoneNumber(mobileNumber: phno)
        phoneNoView.showTextFieldWithText()
        
        validateSaveBtnStatus()
        
        picker.delegate = self
        picker.dataSource = self
        stateView.textField.inputView = picker

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
        
        containerViewWCons.constant = (self.scrollView?.frame.width)!
        containerViewHCons.constant = self.phoneNoView.frame.origin.y + self.phoneNoView.frame.size.height + 10
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        streetView.textField.resignFirstResponder()
        unitView.textField.resignFirstResponder()
        cityView.textField.resignFirstResponder()
        stateView.textField.resignFirstResponder()
        zipView.textField.resignFirstResponder()
        phoneNoView.textField.resignFirstResponder()
    }
    
    @IBAction func actionOnSaveBtn(_ sender: UIButton) {
        streetView.textField.resignFirstResponder()
        unitView.textField.resignFirstResponder()
        cityView.textField.resignFirstResponder()
        stateView.textField.resignFirstResponder()
        zipView.textField.resignFirstResponder()
        phoneNoView.textField.resignFirstResponder()
        
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view.window!)
            let streetAttribute = AWSCognitoIdentityUserAttributeType()
            streetAttribute?.name  = "custom:doctor_addr_street"
            streetAttribute?.value = streetView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            let unitAttribute = AWSCognitoIdentityUserAttributeType()
            unitAttribute?.name  = "custom:doctor_addr_unit"
            unitAttribute?.value = (unitView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! ? "nil" : unitView.textField.text!
            
            let cityAttribute = AWSCognitoIdentityUserAttributeType()
            cityAttribute?.name  = "custom:doctor_addr_city"
            cityAttribute?.value = cityView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            let stateAttribute = AWSCognitoIdentityUserAttributeType()
            stateAttribute?.name  = "custom:doctor_addr_state"
            stateAttribute?.value = stateView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            let zipAttribute = AWSCognitoIdentityUserAttributeType()
            zipAttribute?.name  = "custom:doctor_addr_zip"
            zipAttribute?.value = zipView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            let officePhnoAttribute = AWSCognitoIdentityUserAttributeType()
            officePhnoAttribute?.name  = "custom:doctor_office_phno"
            officePhnoAttribute?.value = "\(Utils.getPhoneNoCountryCode())\(Utils.formatToPhoneNumber(mobileNumber: phoneNoView.textField.text!))"
            
            Utils.getUserPool().currentUser()?.update([streetAttribute!, unitAttribute!, cityAttribute!, stateAttribute!, zipAttribute!, officePhnoAttribute!]).continue({ (task) -> Any? in
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
    
    func updateUserDetails() {
        let user = Utils.user!
        user.doctor_addr_street = self.streetView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        user.doctor_addr_unit = (self.unitView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! ? "nil" : self.unitView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        user.doctor_addr_city = self.cityView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        user.doctor_addr_state = self.stateView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        user.doctor_addr_zip = self.zipView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        user.doctor_office_phno = "\(Utils.getPhoneNoCountryCode())\(Utils.formatToPhoneNumber(mobileNumber: phoneNoView.textField.text!))"
        
        Utils.updateUserDetails(user: user, viewController: self)
    }
    
    // MARK:- Other Methods
    public func validateSaveBtnStatus() {
        if !(streetView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            !(cityView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            !(stateView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            !(phoneNoView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            Utils.formatNumber(mobileNumber: phoneNoView.textField.text!).characters.count == 10 &&
        !(zipView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            ((zipView.textField.text?.characters.count == 5) ||
            (zipView.textField.text?.characters.count == 12)) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func updateTFIndicator() {
        if (streetView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            streetView.hidePositiveIndicator()
        } else {
            streetView.showPositiveIndicator()
        }
        
        if (unitView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            unitView.hidePositiveIndicator()
        } else {
            unitView.showPositiveIndicator()
        }
        
        if (cityView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            cityView.hidePositiveIndicator()
        } else {
            cityView.showPositiveIndicator()
        }
        
        if (stateView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            stateView.hidePositiveIndicator()
        } else {
            stateView.showPositiveIndicator()
        }
        
        if (zipView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!  || ((zipView.textField.text?.characters.count != 5) &&
            (zipView.textField.text?.characters.count != 12)) {
            zipView.hidePositiveIndicator()
        } else {
            zipView.showPositiveIndicator()
        }
        
        if (phoneNoView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            phoneNoView.hidePositiveIndicator()
        } else {
            phoneNoView.showPositiveIndicator()
        }
    }
    
    func singleTap(sender: UITapGestureRecognizer) {
        streetView.textField.resignFirstResponder()
        unitView.textField.resignFirstResponder()
        cityView.textField.resignFirstResponder()
        stateView.textField.resignFirstResponder()
        zipView.textField.resignFirstResponder()
        phoneNoView.textField.resignFirstResponder()
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        self.offSetForKeyboard = 20.0
        
        if streetView.textField == textField {
            streetView.placeHolderText = "Street and number, P.O. Box, etc"
            streetView.hidePositiveIndicator()
        } else if unitView.textField == textField {
            unitView.placeHolderText = "Suite, Unit, Building, etc."
            unitView.hidePositiveIndicator()
        } else if cityView.textField == textField {
            cityView.placeHolderText = "City"
            cityView.hidePositiveIndicator()
        } else if stateView.textField == textField {
            stateView.placeHolderText = "State"
            stateView.hidePositiveIndicator()
             self.picker.selectRow(self.stateList.index(of: self.stateView.textField.text!)!, inComponent: 0, animated: true)
        } else if zipView.textField == textField {
            zipView.placeHolderText = "Zip"
            zipView.hidePositiveIndicator()
        } else if phoneNoView.textField == textField {
            phoneNoView.placeHolderText = "Office Phone Number"
            phoneNoView.hidePositiveIndicator()
        }
    }
    
    func endTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        updateTFIndicator()
        validateSaveBtnStatus()
    }
    
    func shouldReturnTextField(textField: UITextField) {
        textField.resignFirstResponder()
        validateSaveBtnStatus()
    }
    
    func editingChangedTextField(textField: UITextField) {
        validateSaveBtnStatus()
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        
        if phoneNoView.textField == textField {
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

        } else if zipView.textField == textField {
            let length = Utils.getLength(mobileNumber: textField.text!)
            if(length == 9) {
                if(range.length > 0) {
                    let startIndex = textField.text!.index(textField.text!.startIndex, offsetBy: 5)
                    let endIndex = textField.text!.index(textField.text!.startIndex, offsetBy: 8)
                    textField.text = "\(textField.text!.substring(to: startIndex))\(textField.text!.substring(from: endIndex))"
                }
                
                if(range.length == 0) {
                    return false
                }
            } else if (length == 8) {
                if(range.length > 0) {
                } else {
                    let startIndex = textField.text!.index(textField.text!.startIndex, offsetBy: 5)
                    let endIndex = textField.text!.index(textField.text!.startIndex, offsetBy: 5)
                    textField.text = "\(textField.text!.substring(to: startIndex)) - \(textField.text!.substring(from: endIndex))"
                }
            }
            return true
        } else {
            return true
        }
        
    }
    
    func actionOnClearBtn(btn: UIButton) {
        validateSaveBtnStatus()
    }
    
    func getStates() {
        if let path = Bundle.main.path(forResource: "States", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                self.statesDict = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, String>
                let stateArray = Array(self.statesDict!.values)
                self.stateList = stateArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                print(self.stateList)
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    //MARK: - Picker view delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stateList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stateList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateView.textField.text = stateList[row]
    }
}
