//
//  DoctorPromptViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 07/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class DoctorPromptViewController: BaseViewController, customTextFieldProtocol, promptListDelegate {
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var doctorTypes: CustomTextFieldView!
    @IBOutlet weak var doctorTitles: CustomTextFieldView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    
    @IBOutlet weak var doctorTypeErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var doctorTypeErrorView: UIView!
    @IBOutlet weak var doctorTypeErrorLbl: UILabel!
    
    @IBOutlet weak var doctorTitleErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var doctorTitleErrorView: UIView!
    @IBOutlet weak var doctorTitleErrorLbl: UILabel!

    var degreeList = ["CPC", "LCSW", "LMFT", "MD",  "NP", "OD", "PhD", "Psy.D", "PA"]
    var specialtyList = ["Family Practice",  "Internal Medicine", "Medical Assistant", "OB/Gyn", "Pediatrics", "Psychiatry", "Psychology", "Receptionist", "Urology"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        
        doctorTypes.customTextfieldDelegate = self
        doctorTypes.textField.placeholder = "Specialty"
        doctorTypes.floatingLbl.text = "Specialty"
        doctorTitles.customTextfieldDelegate = self
        doctorTitles.textField.placeholder = "Degree"
        doctorTitles.floatingLbl.text = "Degree"
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 4)
        progressView.progress = Utils.signupObj.userRole == "Patient" ? Utils.getProgressPercentage(totoalVal: 5, currentVal: 1) : Utils.getProgressPercentage(totoalVal: 7, currentVal: 1)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        hideAllErrorView()
        progressView.progress = 0.0
        if !Utils.signupObj.doctorType.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            doctorTypes.textField.text! = Utils.signupObj.doctorType
            doctorTypes.showPositiveIndicator()
            doctorTypes.showTextFieldWithText()
        } else {
            doctorTypes.hidePositiveIndicator()
        }
        
        if !Utils.signupObj.doctorTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            doctorTitles.textField.text! = Utils.signupObj.doctorTitle
            doctorTitles.showPositiveIndicator()
            doctorTitles.showTextFieldWithText()
        } else {
            doctorTitles.hidePositiveIndicator()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressView.setProgress(Utils.getProgressPercentage(totoalVal: 7, currentVal: 2), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        doctorTypes.textField.resignFirstResponder()
        doctorTitles.textField.resignFirstResponder()
    }
    
    
    @IBAction func actionOnNextBtn(_ sender: UIButton) {
        doctorTypes.textField.resignFirstResponder()
        doctorTitles.textField.resignFirstResponder()
        validateNextBtnStatus()
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        self.offSetForKeyboard = 20.0
        
        textField.resignFirstResponder()
        if doctorTypes.textField == textField {
            doctorTypes.placeHolderText = "Specialty"
            doctorTypes.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: doctorTypes)
            
            let doctorPromptListVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorPromptListViewController") as! DoctorPromptListViewController
            doctorPromptListVC.itemList = specialtyList
            doctorPromptListVC.promptDelegate = self
            doctorPromptListVC.type = "Doctor_Type"
            doctorPromptListVC.selecteditemIndex = getIndexOfItem(text: textField.text!, type: "Doctor_Type")
            navigationController?.pushViewController(doctorPromptListVC, animated: true)
        } else {
            doctorTitles.placeHolderText = "Degree"
            doctorTitles.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: doctorTitles)

            let doctorPromptListVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorPromptListViewController") as! DoctorPromptListViewController
            doctorPromptListVC.itemList = degreeList
            doctorPromptListVC.promptDelegate = self
            doctorPromptListVC.type = "Doctor_Title"
            doctorPromptListVC.selecteditemIndex = getIndexOfItem(text: textField.text!, type: "Doctor_Title")
            navigationController?.pushViewController(doctorPromptListVC, animated: true)
        }
    }
    
    func endTextFieldEditing(textField: UITextField) {
        self.activeField = textField
        updateTFIndicator()
    }
    
    func shouldReturnTextField(textField: UITextField) {
    }
    
    func editingChangedTextField(textField: UITextField) {
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    // MARK:- Other Methods
    private func goToSignUpEmailVC() {
        let doctorOfficeVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorOfficeViewController") as! DoctorOfficeViewController
        self.navigationController?.pushViewController(doctorOfficeVC, animated: true)
    }
    
    public func validateNextBtnStatus() {
        if (doctorTypes.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: doctorTypes, message: EMPTY_DOCTOR_TYPE)
        } else if (doctorTitles.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            showErrorMsgView(customTextFieldview: doctorTitles, message: EMPTY_DOCTOR_TITLE)
        } else {
            Utils.signupObj.doctorType = doctorTypes.textField.text!
            Utils.signupObj.doctorTitle  = doctorTitles.textField.text!
            self.goToSignUpEmailVC()
        }
    }
    
    func getIndexOfItem(text: String, type: String) -> Int? {
        if type == "Doctor_Type" {
            return specialtyList.index(of: text)
        } else {
            return degreeList.index(of: text)
        }
    }
    
    private func updateTFIndicator() {
        if (doctorTypes.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            doctorTypes.hidePositiveIndicator()
        } else {
            doctorTypes.showPositiveIndicator()
        }
        
        if (doctorTitles.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            doctorTitles.hidePositiveIndicator()
        } else {
            doctorTitles.showPositiveIndicator()
        }
    }
    
    func singleTap(sender: UITapGestureRecognizer) {
        doctorTypes.textField.resignFirstResponder()
        doctorTitles.textField.resignFirstResponder()
    }
    
    //MARK:- Prompt list delegate
    func selectedItem(type: String, index: Int) {
        if type == "Doctor_Type" {
            Utils.signupObj.doctorType = specialtyList[index]
            doctorTypes.textField.text = specialtyList[index]
        } else {
            Utils.signupObj.doctorTitle = degreeList[index]
            doctorTitles.textField.text = degreeList[index]
        }
        
    }
    
    func showErrorMsgView(customTextFieldview: CustomTextFieldView, message: String) {
        if customTextFieldview == doctorTitles {
            doctorTitleErrorView.isHidden = false
            doctorTitleErrorHCons.constant = 40
            doctorTitleErrorLbl.text = message
            doctorTitles.errorConfiguration()
            adjustLayouts()
        } else {
            doctorTypeErrorView.isHidden = false
            doctorTypeErrorHCons.constant = 40
            doctorTypeErrorLbl.text = message
            doctorTypes.errorConfiguration()
            adjustLayouts()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == doctorTitles {
            doctorTitleErrorView.isHidden = true
            doctorTitleErrorHCons.constant = 0
            adjustLayouts()
        } else {
            doctorTypeErrorView.isHidden = true
            doctorTypeErrorHCons.constant = 0
            adjustLayouts()
        }
    }
    
    func hideAllErrorView() {
        hideErrorMsgView(customTextFieldview: doctorTitles)
        hideErrorMsgView(customTextFieldview: doctorTypes)
    }
}
