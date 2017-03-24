//
//  ChangeDOBViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 08/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ChangeDOBViewController: UIViewController, customTextFieldProtocol, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var DOBErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var DOBErrorView: UIView!
    @IBOutlet weak var DOBErrorLbl: UILabel!
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var dobVIew: CustomTextFieldView!
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        datePicker.datePickerMode = .date
        datePicker.date = Utils.convertDateFromStringForDatePicker(dateString: Utils.user.dateOfBirth!)
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(SignupEmailPwdDobViewController.datePickerValueChange(datePicker:)), for: .valueChanged)
        
        dobVIew.customTextfieldDelegate = self
        dobVIew.textField.placeholder = "Date of Birth"
        dobVIew.floatingLbl.text = "Date of Birth"
        dobVIew.textField.text = Utils.user.dateOfBirth!
        dobVIew.textField.inputView = datePicker
        dobVIew.showTextFieldWithText()
        dobVIew.textField.rightViewMode = UITextFieldViewMode.never
        
        validateSaveBtnStatus()
        hideErrorMsgView(customTextFieldview: dobVIew)
    }
    
    //MARK:- Other Methods
    func setBackButton() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackChevron") , style: .plain, target: self, action: #selector(BaseViewController.actionOnBackBtn(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    
    func actionOnBackBtn(sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func actionOnSaveBtn(_ sender: UIBarButtonItem) {
        dobVIew.textField.resignFirstResponder()
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view.window!)
            let attribute = AWSCognitoIdentityUserAttributeType()
            attribute?.name  = "birthdate"
            attribute?.value = dobVIew.textField.text!
            
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
    
    func datePickerValueChange(datePicker: UIDatePicker) {
        dobVIew.textField.text = Utils.convertStringFromDateForDatePicker(date: datePicker.date)
        
        if Utils.getAgeFromDate(birthday: dobVIew.textField.text!) < 18  {
            showErrorMsgView(customTextFieldview: dobVIew, message: DOB_18_YEARS)
        } else {
            hideErrorMsgView(customTextFieldview: dobVIew)
            dobVIew.addSelectedConfig()
        }

        validateSaveBtnStatus()
    }
    
    public func validateSaveBtnStatus() {
        if !(dobVIew.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && Utils.getAgeFromDate(birthday: dobVIew.textField.text!) >= 18 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func updateTFIndicator() {
        if (dobVIew.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && Utils.getAgeFromDate(birthday: dobVIew.textField.text!) < 18 {
            dobVIew.hidePositiveIndicator()
        } else {
            dobVIew.showPositiveIndicator()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func updateUserDetails() {
        let user = Utils.user!
        user.dateOfBirth = dobVIew.textField.text!
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
        dobVIew.placeHolderText = "Date of Birth"
        dobVIew.hidePositiveIndicator()
        dobVIew.textField.rightViewMode = UITextFieldViewMode.never
    }
    
    func endTextFieldEditing(textField: UITextField) {
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
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
        validateSaveBtnStatus()
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == dobVIew {
            DOBErrorView.isHidden = false
            DOBErrorHCons.constant = 40
            DOBErrorLbl.text = message
            dobVIew.errorConfiguration()
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == dobVIew {
            DOBErrorView.isHidden = true
            DOBErrorHCons.constant = 0
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
        }
    }
}
