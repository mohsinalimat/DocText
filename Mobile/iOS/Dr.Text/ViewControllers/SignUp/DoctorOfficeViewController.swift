//
//  DoctorOfficeViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 07/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class DoctorOfficeViewController: BaseViewController, customTextFieldProtocol, baseViewControllerProtocolDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var streetErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var streetErrorView: UIView!
    @IBOutlet weak var streetErrorLbl: UILabel!
    
    @IBOutlet weak var unitErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var unitErrorView: UIView!
    @IBOutlet weak var unitErrorLbl: UILabel!
    
    @IBOutlet weak var cityErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var cityErrorView: UIView!
    @IBOutlet weak var cityErrorLbl: UILabel!
    
    @IBOutlet weak var stateErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var stateErrorView: UIView!
    @IBOutlet weak var stateErrorLbl: UILabel!
    
    @IBOutlet weak var zipErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var zipErrorView: UIView!
    @IBOutlet weak var zipErrorLbl: UILabel!
    
    @IBOutlet weak var phoneNoErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var phoneNoErrorView: UIView!
    @IBOutlet weak var phoneNoErrorLbl: UILabel!
    
    @IBOutlet weak var streetView: CustomTextFieldView!
    @IBOutlet weak var unitView: CustomTextFieldView!
    @IBOutlet weak var cityView: CustomTextFieldView!
    @IBOutlet weak var stateView: CustomTextFieldView!
    @IBOutlet weak var zipView: CustomTextFieldView!
    @IBOutlet weak var phoneNoView: CustomTextFieldView!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    //    let location = GetLocation()
    var locationManager = CLLocationManager()
    var stateList = [String]()
    var statesDict: Dictionary<String, String>?
    var picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        getStates()
        setTapGesture()
        streetView.customTextfieldDelegate = self
        streetView.textField.placeholder = "Street Number and Street"
        streetView.floatingLbl.text = "Street Number and Street"
        
        unitView.customTextfieldDelegate = self
        unitView.textField.placeholder = "Suite, Unit, Building, etc."
        unitView.floatingLbl.text = "Suite, Unit, Building, etc."
        
        cityView.customTextfieldDelegate = self
        cityView.textField.placeholder = "City"
        cityView.floatingLbl.text = "City"
        
        stateView.customTextfieldDelegate = self
        stateView.textField.placeholder = "State"
        stateView.floatingLbl.text = "State"
        
        zipView.customTextfieldDelegate = self
        zipView.textField.placeholder = "Zip"
        zipView.textField.keyboardType = .numberPad
        zipView.textField.keyboardAppearance = .default
        zipView.floatingLbl.text = "Zip"
        
        phoneNoView.customTextfieldDelegate = self
        phoneNoView.textField.placeholder = "Office Phone Number"
        phoneNoView.textField.keyboardType = .numberPad
        phoneNoView.textField.keyboardAppearance = .default
        phoneNoView.floatingLbl.text = "Office Phone Number"
        
        
     
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 4)
        progressView.progress = Utils.getProgressPercentage(totoalVal: 7, currentVal: 2)
        
        hideAllErrorView()
        self.activeField = streetView.textField
        if Utils.signupObj.doctor_addr_city.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty && Utils.signupObj.doctor_addr_state.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            setUpCurrentLocation()
        }
        
        picker.delegate = self
        picker.dataSource = self
        stateView.textField.inputView = picker
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewWCons.constant = (self.scrollView?.frame.width)!
        containerViewHCons.constant = self.phoneNoView.frame.origin.y + self.phoneNoView.frame.size.height + 30
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardDelegate = self
        navigationController?.isNavigationBarHidden = false
        progressView.progress = 0.0
        if !Utils.signupObj.doctor_addr_street.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            streetView.textField.text! = Utils.signupObj.doctor_addr_street
            streetView.showPositiveIndicator()
            streetView.showTextFieldWithText()
        } else {
            streetView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.doctor_addr_unit.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            unitView.textField.text! = Utils.signupObj.doctor_addr_unit
            unitView.showPositiveIndicator()
            unitView.showTextFieldWithText()
        } else {
            unitView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.doctor_addr_city.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            cityView.textField.text! = Utils.signupObj.doctor_addr_city
            cityView.showPositiveIndicator()
            cityView.showTextFieldWithText()
        } else {
            cityView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.doctor_addr_state.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            stateView.textField.text! = Utils.signupObj.doctor_addr_state
            stateView.showPositiveIndicator()
            stateView.showTextFieldWithText()
        } else {
            stateView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.doctor_addr_zip.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            zipView.textField.text! = Utils.signupObj.doctor_addr_zip
            zipView.showPositiveIndicator()
            zipView.showTextFieldWithText()
        } else {
            zipView.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.doctor_office_phNo.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            let phno = Utils.signupObj.doctor_office_phNo.replacingOccurrences(of: Utils.signupObj.phNoCountryCode, with: "")
            phoneNoView.textField.text! = Utils.formatToPhoneNumber(mobileNumber: phno)
            phoneNoView.showPositiveIndicator()
            phoneNoView.showTextFieldWithText()
        } else {
            phoneNoView.hidePositiveIndicator()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressView.setProgress(Utils.getProgressPercentage(totoalVal: 7, currentVal: 3), animated: true)
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
    
    
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        moveToNextTextField()
    }
    
    // MARK:- Other Methods
    private func goToSignUpEmailVC() {
        streetView.textField.resignFirstResponder()
        unitView.textField.resignFirstResponder()
        cityView.textField.resignFirstResponder()
        stateView.textField.resignFirstResponder()
        zipView.textField.resignFirstResponder()
        phoneNoView.textField.resignFirstResponder()
        
        let signUpEPDVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorEmailPWDViewController") as! DoctorEmailPWDViewController
        self.navigationController?.pushViewController(signUpEPDVC, animated: true)
    }
    
    public func validateNextBtnStatus() {
        if (streetView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: streetView, message: EMPTY_STREET)
        } else if (cityView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: cityView, message: EMPTY_CITY)
        } else if (stateView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: stateView, message: EMPTY_STATE)
        } else if (phoneNoView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: phoneNoView, message: EMPTY_PHONE_NO)
        } else if Utils.formatNumber(mobileNumber: phoneNoView.textField.text!).characters.count != 10 {
            showErrorMsgView(customTextFieldview: phoneNoView, message: PHNO_10_CHAR)
        } else if (zipView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: zipView, message: EMPTY_ZIP)
        } else if (zipView.textField.text?.characters.count != 5) && (zipView.textField.text?.characters.count != 12) {
            showErrorMsgView(customTextFieldview: zipView, message: ZIP_NOT_VALID)
        } else {
            Utils.signupObj.doctor_addr_street = streetView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            Utils.signupObj.doctor_addr_unit = unitView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            Utils.signupObj.doctor_addr_city = cityView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            Utils.signupObj.doctor_addr_state = stateView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            Utils.signupObj.doctor_addr_zip = zipView.textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            Utils.signupObj.doctor_office_phNo = "\(Utils.getPhoneNoCountryCode())\(Utils.formatNumber(mobileNumber: phoneNoView.textField.text!))"
            Utils.signupObj.phNoCountryCode = Utils.getPhoneNoCountryCode()
            goToSignUpEmailVC()
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
        
        if (zipView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || ((zipView.textField.text?.characters.count != 5) &&
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
        self.offSetForKeyboard = 35.0
        
        if streetView.textField == textField {
            streetView.placeHolderText = "Street Number and Street"
            streetView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: streetView)
        } else if unitView.textField == textField {
            unitView.placeHolderText = "Suite, Unit, Building, etc."
            unitView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: unitView)
        } else if cityView.textField == textField {
            cityView.placeHolderText = "City"
            cityView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: cityView)
        } else if stateView.textField == textField {
            stateView.placeHolderText = "State"
            stateView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: stateView)
            
            if let index = self.stateList.index(of: self.stateView.textField.text!) {
                self.picker.selectRow(index, inComponent: 0, animated: true)
            }
        } else if zipView.textField == textField {
            zipView.placeHolderText = "Zip"
            zipView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: zipView)
        } else if phoneNoView.textField == textField {
            phoneNoView.placeHolderText = "Office Phone Number"
            phoneNoView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: phoneNoView)
        }
    }
    
    func endTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        updateTFIndicator()
        if textField == streetView.textField {
            if (streetView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: streetView, message: EMPTY_STREET)
            }
        } else if textField == cityView.textField {
            if (cityView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: cityView, message: EMPTY_CITY)
            }
        } else if textField == stateView.textField {
            if (stateView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: stateView, message: EMPTY_STATE)
            }
        } else if textField == zipView.textField {
            if (zipView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: zipView, message: EMPTY_ZIP)
            } else if (zipView.textField.text?.characters.count != 5) && (zipView.textField.text?.characters.count != 12) {
                showErrorMsgView(customTextFieldview: zipView, message: ZIP_NOT_VALID)
            }
        } else if textField == phoneNoView.textField {
            if (phoneNoView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: phoneNoView, message: EMPTY_PHONE_NO)
            }
        }
    }
    
    func shouldReturnTextField(textField: UITextField) {
      
        moveToNextTextField()
    }
    
    func moveToNextTextField() {
        
        if !(streetView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            !(cityView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && !(stateView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            !(phoneNoView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! &&
            Utils.formatNumber(mobileNumber: phoneNoView.textField.text!).characters.count == 10 &&
            !(zipView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            validateNextBtnStatus()
        } else {
            if self.activeField == streetView.textField {
                if (streetView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: streetView, message: EMPTY_STREET)
                } else {
                    unitView.textField.becomeFirstResponder()
                }
            } else if self.activeField == unitView.textField {
                cityView.textField.becomeFirstResponder()
            } else if self.activeField == cityView.textField {
                if (cityView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: cityView, message: EMPTY_CITY)
                } else {
                    stateView.textField.becomeFirstResponder()
                }
            } else if self.activeField == stateView.textField {
                if (stateView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: stateView, message: EMPTY_STATE)
                } else {
                    zipView.textField.becomeFirstResponder()
                }
            } else if self.activeField == zipView.textField {
                if (zipView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: zipView, message: EMPTY_ZIP)
                } else if (zipView.textField.text?.characters.count != 5) && (zipView.textField.text?.characters.count != 12) {
                    showErrorMsgView(customTextFieldview: zipView, message: ZIP_NOT_VALID)
                } else {
                    phoneNoView.textField.becomeFirstResponder()
                }
            } else if self.activeField == phoneNoView.textField {
                if (phoneNoView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                    showErrorMsgView(customTextFieldview: phoneNoView, message: EMPTY_PHONE_NO)
                } else {
                    validateNextBtnStatus()
                }
            }
        }
    }
    
    func editingChangedTextField(textField: UITextField) {
        
        if textField == streetView.textField {
            hideErrorMsgView(customTextFieldview: streetView)
            streetView.addSelectedConfig()
        } else if textField == unitView.textField {
            hideErrorMsgView(customTextFieldview: unitView)
            unitView.addSelectedConfig()
        } else if textField == cityView.textField {
            hideErrorMsgView(customTextFieldview: cityView)
            cityView.addSelectedConfig()
        } else if textField == stateView.textField {
            hideErrorMsgView(customTextFieldview: stateView)
            stateView.addSelectedConfig()
        } else if textField == zipView.textField {
            hideErrorMsgView(customTextFieldview: zipView)
            zipView.addSelectedConfig()
        } else if textField == phoneNoView.textField {
            hideErrorMsgView(customTextFieldview: phoneNoView)
            phoneNoView.addSelectedConfig()
        }
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
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == streetView {
            streetErrorView.isHidden = false
            streetErrorHCons.constant = 40
            streetErrorLbl.text = message
            streetView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == unitView {
            unitErrorView.isHidden = false
            unitErrorHCons.constant = 40
            unitErrorLbl.text = message
            unitView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == cityView {
            cityErrorView.isHidden = false
            cityErrorHCons.constant = 40
            cityErrorLbl.text = message
            cityView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == stateView {
            stateErrorView.isHidden = false
            stateErrorHCons.constant = 40
            stateErrorLbl.text = message
            stateView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == zipView {
            zipErrorView.isHidden = false
            zipErrorHCons.constant = 40
            zipErrorLbl.text = message
            zipView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == phoneNoView {
            phoneNoErrorView.isHidden = false
            phoneNoErrorHCons.constant = 40
            phoneNoErrorLbl.text = message
            phoneNoView.errorConfiguration()
            adjustLayouts()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == streetView {
            streetErrorView.isHidden = true
            streetErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == unitView {
            unitErrorView.isHidden = true
            unitErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == cityView {
            cityErrorView.isHidden = true
            cityErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == stateView {
            stateErrorView.isHidden = true
            stateErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == zipView {
            zipErrorView.isHidden = true
            zipErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == phoneNoView {
            phoneNoErrorView.isHidden = true
            phoneNoErrorHCons.constant = 0
            adjustLayouts()
        }
    }
    
    func hideAllErrorView() {
        hideErrorMsgView(customTextFieldview: streetView)
        hideErrorMsgView(customTextFieldview: unitView)
        hideErrorMsgView(customTextFieldview: cityView)
        hideErrorMsgView(customTextFieldview: stateView)
        hideErrorMsgView(customTextFieldview: zipView)
        hideErrorMsgView(customTextFieldview: phoneNoView)
    }
    
    func keyboardSize(size: CGSize) {
        self.nextBtnBCons.constant = size.height
        UIView.animate(withDuration: 0.50, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    
    func setUpCurrentLocation() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let location = manager.location!
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        Utils.showHUD(view: self.view)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            DispatchQueue.main.async {
                Utils.hideHUD(view: self.view)
                if error != nil {
                    print("Error getting location: \(error)")
                } else {
                    let placeArray = placemarks as [CLPlacemark]!
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    if placeMark.locality != nil {
                        self.cityView.textField.text! = placeMark.locality!
                        Utils.signupObj.doctor_addr_city = placeMark.locality!
                        self.cityView.showPositiveIndicator()
                        self.cityView.showTextFieldWithText()
                    }
                    if placeMark.administrativeArea != nil {
                        
                        if let state = self.statesDict![placeMark.administrativeArea!] {
                            self.stateView.textField.text! = state
                            Utils.signupObj.doctor_addr_state = state
                            self.picker.selectRow(self.stateList.index(of: state)!, inComponent: 0, animated: true)
                        } else {
                            self.stateView.textField.text! = placeMark.administrativeArea!
                            Utils.signupObj.doctor_addr_state = placeMark.administrativeArea!
                        }
                        
                        
                        self.stateView.showPositiveIndicator()
                        self.stateView.showTextFieldWithText()
                    }
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
