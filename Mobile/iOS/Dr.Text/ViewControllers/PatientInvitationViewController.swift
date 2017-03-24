//
//  PatientInvitationViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 14/11/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class PatientInvitationViewController: BaseViewController, customTextFieldProtocol, baseViewControllerProtocolDelegate {
    
    @IBOutlet weak var phNoErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var phNoErrorView: UIView!
    @IBOutlet weak var phNoErrorLbl: UILabel!
    
    @IBOutlet weak var phoneNoView: CustomTextFieldView!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyboardDelegate = self
        setBackButton()
        
        phoneNoView.customTextfieldDelegate = self
        phoneNoView.textField.placeholder = "Phone number"
        phoneNoView.textField.keyboardType = .numberPad
        phoneNoView.floatingLbl.text = "Phone number"
        phoneNoView.textField.keyboardAppearance = .default
        hideAllErrorView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
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
        } else {
            Utils.signupObj.phoneNumber = Utils.formatNumber(mobileNumber: phoneNoView.textField.text!)
            invitePatient()
        }
        
    }
    
    
    private func updateTFIndicator() {
        if (phoneNoView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (Utils.formatNumber(mobileNumber: phoneNoView.textField.text!).characters.count != 10) {
            phoneNoView.hidePositiveIndicator()
        } else {
            phoneNoView.showPositiveIndicator()
        }
    }
    
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        validateNextBtnStatus()
    }
    
    func invitePatient() {
        phoneNoView.textField.resignFirstResponder()
        
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            let phoneNo = "\(Utils.getPhoneNoCountryCode())\(Utils.formatNumber(mobileNumber: phoneNoView.textField.text!))"
            let doctorId = Utils.getCurrentUser().emailID!
            DocTextApi.invitePatient(doctorId: doctorId, phoneNo: phoneNo, completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if error != nil {
                        Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                    } else {
                        if result != nil {
                            let arr = result!.components(separatedBy: ",")
                            if arr.count >= 1 {
                                if arr[0] == "Success" {
                                    let alertController = UIAlertController(title: "", message: "Invitee code sent \(arr[1])", preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                                        _ = self.navigationController?.popViewController(animated: true)
                                    }
                                    alertController.addAction(OKAction)
                                    self.present(alertController, animated: true, completion:nil)
                                    
                                } else {
                                    Utils.showAlert(title: "Error", message: "Invitation code sent fails", viewController: self)
                                }
                            }
                        }
                    }
                }
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
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
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == phoneNoView {
            phNoErrorView.isHidden = true
            phNoErrorHCons.constant = 0
            adjustLayouts()
        }
    }
    
    func hideAllErrorView() {
        hideErrorMsgView(customTextFieldview: phoneNoView)
    }
}
