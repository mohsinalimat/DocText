//
//  DoctorChargeViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 18/01/17.
//  Copyright © 2017 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class DoctorChargeViewController: BaseViewController, customTextFieldProtocol, baseViewControllerProtocolDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    
    // MARK:- IBOutlets
    @IBOutlet weak var amountErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var amountErrorView: UIView!
    @IBOutlet weak var amountErrorLbl: UILabel!
    @IBOutlet weak var amountTextFieldView: CustomTextFieldView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    var isUpdateCharge: Bool?
    var picker = UIPickerView()
    var amount = [String]()
    
    // MARK:- UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
         setTapGesture()
        if !self.isUpdateCharge! {
            self.navigationItem.hidesBackButton = true
        } else {
            self.navigationItem.hidesBackButton = false
            setBackButton()
        }
        
        
        for index in 0...100 {
            amount.append("$\(index)")
        }
        
        amountTextFieldView.customTextfieldDelegate = self
        amountTextFieldView.textField.placeholder = "Amount"
        amountTextFieldView.floatingLbl.text = "Amount"
        
        hideErrorMsgView(customTextFieldview: amountTextFieldView)
        self.activeField = amountTextFieldView.textField
        
        picker.delegate = self
        picker.dataSource = self
        amountTextFieldView.textField.inputView = picker
        nextBtn.setTitle("Done", for: .normal)
        
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
        
        self.keyboardDelegate = self
        if Utils.user.doctorCharge! != "nil" {
            amountTextFieldView.textField.text! = Utils.user.doctorCharge!
            amountTextFieldView.showPositiveIndicator()
            amountTextFieldView.showTextFieldWithText()
            self.picker.selectRow(self.amount.index(of: self.amountTextFieldView.textField.text!)!, inComponent: 0, animated: true)
        } else {
            amountTextFieldView.hidePositiveIndicator()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        amountTextFieldView.textField.resignFirstResponder()
    }
    
    // MARK:- IBAction
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        moveToNextTextField()
    }
    
    // MARK:- Other Methods
    private func updateDoctorCharge() {
        amountTextFieldView.textField.resignFirstResponder()
        
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view.window!)
            let attribute = AWSCognitoIdentityUserAttributeType()
            attribute?.name  = "custom:doctor_charge"
            attribute?.value = amountTextFieldView.textField.text!
            
            Utils.getUserPool().currentUser()?.update([attribute!]).continue({ (task) -> Any? in
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
        user.doctorCharge = amountTextFieldView.textField.text!
        self.updateUserDetails(user: user, viewController: self)
    }
    
    public func validateNextBtnStatus() {
        
        if (amountTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: amountTextFieldView, message: DOCTOR_CHARGE_EMPTY)
        } else {
            Utils.signupObj.doctor_charge = amountTextFieldView.textField.text!
            updateDoctorCharge()
        }
    }
    
    private func updateTFIndicator() {
        if (amountTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            amountTextFieldView.hidePositiveIndicator()
        } else {
            amountTextFieldView.showPositiveIndicator()
        }
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        if amountTextFieldView.textField == textField {
            amountTextFieldView.placeHolderText = "Amount"
            amountTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: amountTextFieldView)
        }
        self.offSetForKeyboard = 20.0
        self.activeField = textField
    }
    
    func endTextFieldEditing(textField: UITextField) {
        updateTFIndicator()
        if self.activeField == amountTextFieldView.textField {
            if (amountTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: amountTextFieldView, message: DOCTOR_CHARGE_EMPTY)
            }
        }
    }
    
    func shouldReturnTextField(textField: UITextField) {
        moveToNextTextField()
    }
    
    func editingChangedTextField(textField: UITextField) {
        if textField == amountTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: amountTextFieldView)
            amountTextFieldView.addSelectedConfig()
        }
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    func moveToNextTextField() {
        
        if !(amountTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            validateNextBtnStatus()
        } else {
            if (amountTextFieldView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
                showErrorMsgView(customTextFieldview: amountTextFieldView, message: EMPTY_LAST_NAME)
            } else {
                validateNextBtnStatus()
            }
        }
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == amountTextFieldView {
            amountErrorView.isHidden = false
            amountErrorHCons.constant = 40
            amountErrorLbl.text = message
            amountTextFieldView.errorConfiguration()
            adjustLayouts()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == amountTextFieldView {
            amountErrorView.isHidden = true
            amountErrorHCons.constant = 0
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
    
    //MARK: - Picker view delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return amount.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return amount[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.amountTextFieldView.textField.text = amount[row]
        hideErrorMsgView(customTextFieldview: amountTextFieldView)
        amountTextFieldView.addSelectedConfig()
    }
    
    func updateUserDetails(user: User, viewController: UIViewController) {
        Utils.showHUD(view: viewController.view.window!)
        
        DocTextApi.updateUser(user: user) { (result, error) in
            DispatchQueue.main.async {
                Utils.hideHUD(view: viewController.view.window!)
                if error != nil {
                    Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: viewController)
                } else {
                    if result == "success" {
                        Utils.user.firstName = user.firstName!
                        Utils.user.lastName = user.lastName!
                        Utils.user.profilePicUrl = user.profilePicUrl
                        Utils.user.dateOfBirth = user.dateOfBirth!
                        Utils.user.doctorTitle = user.doctorTitle!
                        Utils.user.doctorType = user.doctorType!
                        Utils.user.doctor_addr_street = user.doctor_addr_street!
                        Utils.user.doctor_addr_unit = user.doctor_addr_unit!
                        Utils.user.doctor_addr_city = user.doctor_addr_city!
                        Utils.user.doctor_addr_state = user.doctor_addr_state!
                        Utils.user.doctor_addr_zip = user.doctor_addr_zip!
                        Utils.user.doctor_office_phno = user.doctor_office_phno!
                        Utils.user.doctorCharge = user.doctorCharge!
                        
                        if !self.isUpdateCharge! {
                            let tabbarVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                            tabbarVC.selectedIndex = 2
                            tabbarVC.modalPresentationStyle = .custom
                            tabbarVC.modalTransitionStyle = .crossDissolve
                            
                            let navigationController = UINavigationController(rootViewController: tabbarVC)
                            navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.9907117486, green: 0.8272568583, blue: 0.349744916, alpha: 1)
                            navigationController.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                            navigationController.navigationBar.isTranslucent = false
                            
                            self.present(navigationController, animated: true, completion: nil)
                        } else {
                            _ = viewController.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        Utils.showAlert(title: "Error Found", message: "Something went wrong!", viewController: viewController)
                    }
                }
            }
        }
    }
}
