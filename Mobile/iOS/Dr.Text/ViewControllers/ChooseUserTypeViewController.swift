//
//  ChooseUserTypeViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 05/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class ChooseUserTypeViewController: BaseViewController {
    
    @IBOutlet weak var patientBtn: UIButton!
    @IBOutlet weak var doctorBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        buttonConfiguration()
        Utils.emptySignUpVar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        
        if Utils.signupObj.userRole == "Doctor" {
            enableBtn(btn: doctorBtn)
            disableBtn(btn: patientBtn)
            Utils.enableNextBtn(button: nextBtn)
        } else if Utils.signupObj.userRole == "Patient" {
            enableBtn(btn: patientBtn)
            disableBtn(btn: doctorBtn)
            Utils.enableNextBtn(button: nextBtn)
        } else {
            disableBtn(btn: doctorBtn)
            disableBtn(btn: patientBtn)
            Utils.disableNextBtn(button: nextBtn)
        }
    }
    
    public func validateBtnStatus() {
        if patientBtn.tag == 1 {
            enableBtn(btn: doctorBtn)
            disableBtn(btn: patientBtn)
            Utils.signupObj.userRole = "Doctor"
        } else {
            enableBtn(btn: patientBtn)
            disableBtn(btn: doctorBtn)
            Utils.signupObj.userRole = "Patient"
        }
    }
    
    @IBAction func actionOnDoctor(_ sender: UIButton) {
        patientBtn.tag = 1
        doctorBtn.tag = 0
        validateBtnStatus()
        Utils.enableNextBtn(button: nextBtn)
    }
    
    @IBAction func actionOnPatient(_ sender: UIButton) {
        patientBtn.tag = 0
        doctorBtn.tag = 1
        validateBtnStatus()
        Utils.enableNextBtn(button: nextBtn)
    }
    
    @IBAction func actionOnNextBnt(_ sender: UIButton) {
        let signUpVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "SignUpViewController")
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    private func enableBtn(btn: UIButton) {
        btn.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1)
        btn.layer.borderWidth = 0.0
    }
    
    private func disableBtn(btn: UIButton) {
        btn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        btn.layer.borderWidth = 1.0
    }
    
    private func buttonConfiguration() {
        patientBtn.layer.masksToBounds = true
        patientBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        patientBtn.layer.borderColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1).cgColor
        patientBtn.layer.borderWidth = 1.0
        patientBtn.tag = 0
        
        doctorBtn.layer.masksToBounds = true
        doctorBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        doctorBtn.layer.borderColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1).cgColor
        doctorBtn.layer.borderWidth = 1.0
        doctorBtn.tag = 0
    }
}
