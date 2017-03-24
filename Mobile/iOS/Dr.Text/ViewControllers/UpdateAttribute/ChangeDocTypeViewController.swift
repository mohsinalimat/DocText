//
//  ChangeDocTypeViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 09/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ChangeDocTypeViewController: UIViewController, customTextFieldProtocol, promptListDelegate {
    
    @IBOutlet weak var saveBarBtnItm: UIBarButtonItem!
    @IBOutlet weak var doctorTypes: CustomTextFieldView!
    var specialtyList = ["Family Practice", "Internal Medicine", "Pediatrics", "OB/Gyn", "Urology", "Psychiatry", "Psychology"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        
        doctorTypes.customTextfieldDelegate = self
        doctorTypes.textField.placeholder = "Specialty"
        doctorTypes.floatingLbl.text = "Specialty"
        doctorTypes.textField.text = Utils.user.doctorType!
        doctorTypes.showTextFieldWithText()
        validateSaveBtnStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doctorTypes.textField.resignFirstResponder()
    }
    
    
    @IBAction func actionOnSaveBtn(_ sender: UIButton) {
        doctorTypes.textField.resignFirstResponder()
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view.window!)
            let attribute = AWSCognitoIdentityUserAttributeType()
            attribute?.name  = "custom:doctorType"
            attribute?.value = doctorTypes.textField.text!
            
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
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        
        doctorTypes.placeHolderText = "Specialty"
        doctorTypes.hidePositiveIndicator()
        textField.resignFirstResponder()

        let doctorPromptListVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorPromptListViewController") as! DoctorPromptListViewController
        doctorPromptListVC.itemList = specialtyList
        doctorPromptListVC.promptDelegate = self
        doctorPromptListVC.type = "Doctor_Type"
        doctorPromptListVC.selecteditemIndex = getIndexOfItem(text: textField.text!, type: "Doctor_Type")
        navigationController?.pushViewController(doctorPromptListVC, animated: true)
    }
    
    func endTextFieldEditing(textField: UITextField) {
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
        return true
    }
    
    // MARK:- Other Methods
    private func goToSignUpEmailVC() {
        let doctorOfficeVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorOfficeViewController") as! DoctorOfficeViewController
        self.navigationController?.pushViewController(doctorOfficeVC, animated: true)
    }
    
    public func validateSaveBtnStatus() {
        if !(doctorTypes.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func updateTFIndicator() {
        if (doctorTypes.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            doctorTypes.hidePositiveIndicator()
        } else {
            doctorTypes.showPositiveIndicator()
        }
    }
    
    func singleTap(sender: UITapGestureRecognizer) {
        doctorTypes.textField.resignFirstResponder()
    }
    
    func setBackButton() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackChevron") , style: .plain, target: self, action: #selector(BaseViewController.actionOnBackBtn(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    
    func actionOnBackBtn(sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
    
    func actionOnClearBtn(btn: UIButton) {
        validateSaveBtnStatus()
    }
    
    func getIndexOfItem(text: String, type: String) -> Int? {
        return specialtyList.index(of: text)
    }
    
    func updateUserDetails() {
        let user = Utils.user!
        user.doctorType = doctorTypes.textField.text!
        Utils.updateUserDetails(user: user, viewController: self)
    }
    

    //MARK:- Prompt list delegate
    func selectedItem(type: String, index: Int) {
        doctorTypes.textField.text = specialtyList[index]
        validateSaveBtnStatus()
    }
}
