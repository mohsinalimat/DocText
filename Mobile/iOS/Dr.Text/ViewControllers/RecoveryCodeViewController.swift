//
//  RecoveryCodeViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 10/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class RecoveryCodeViewController: BaseViewController, baseViewControllerProtocolDelegate, UITextFieldDelegate, ResetPwdProtocolDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- IBOutlets
    @IBOutlet weak var resendCodeTCons: NSLayoutConstraint!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var fristDigitLbl: UILabel!
    @IBOutlet weak var secondDigitLbl: UILabel!
    @IBOutlet weak var thirdDigitLbl: UILabel!
    @IBOutlet weak var fourthDigitLbl: UILabel!
    @IBOutlet weak var fifthDigitLbl: UILabel!
    @IBOutlet weak var sixthDigitLbl: UILabel!
    @IBOutlet weak var dummyTextField: dumTextField!
    public var emailID: String!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    
    // MARK:- UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        self.navigationItem.hidesBackButton = true
        dummyTextField.becomeFirstResponder()
        dummyTextField.addTarget(self, action: #selector(textChangedAction), for: .editingChanged)
        errorView.isHidden = true
        
        setEmptyLblProperty(label: fristDigitLbl)
        setEmptyLblProperty(label: secondDigitLbl)
        setEmptyLblProperty(label: thirdDigitLbl)
        setEmptyLblProperty(label: fourthDigitLbl)
        setEmptyLblProperty(label: fifthDigitLbl)
        setEmptyLblProperty(label: sixthDigitLbl)
        
    }
    
    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChangePWDViewController.actionOnTapGesture(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func actionOnTapGesture(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dummyTextField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }

    
    // MARK:- IBAction
    @IBAction func actionOnResendCode(_ sender: UIButton) {
        let user = Utils.getUserPool().getUser(emailID)
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view)
            user.forgotPassword().continue({ (task) -> Any? in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view)
                    if task.error != nil {
                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                        print(((task.error as! NSError).userInfo["message"] as? String)!)
                        Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                    } else {
                        print("verification code for forgot password sent successfully")
                        Utils.showAlert(title: "", message: "Verification code has been resent successfully", viewController: self)
                    }
                }
                return nil
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
        
        
        
        
        
    }
    
    // MARK:- UITextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count > 0 && !Scanner(string: string).scanInt(nil) {
            return false
        }
        
        let oldLength = textField.text?.characters.count
        let replacementLength = string.characters.count
        let rangeLength = range.length
        
        let newLength = oldLength! -  rangeLength + replacementLength
        
        if newLength > 6 {
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.offSetForKeyboard = 60.0
        self.activeField = textField
    }

    func textChangedAction() {
        let text = dummyTextField.text!
        errorView.isHidden = true
        moveResendBtnToTop()
        if text.characters.count == 0 {
            setEmptyLblProperty(label: fristDigitLbl)
            setEmptyLblProperty(label: secondDigitLbl)
            setEmptyLblProperty(label: thirdDigitLbl)
            setEmptyLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 1 {
            fristDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setEmptyLblProperty(label: secondDigitLbl)
            setEmptyLblProperty(label: thirdDigitLbl)
            setEmptyLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 2 {
            secondDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setEmptyLblProperty(label: thirdDigitLbl)
            setEmptyLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 3 {
            thirdDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setFilledLblProperty(label: thirdDigitLbl)
            setEmptyLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 4 {
            fourthDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setFilledLblProperty(label: thirdDigitLbl)
            setFilledLblProperty(label: fourthDigitLbl)
            setEmptyLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 5 {
            fifthDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setFilledLblProperty(label: thirdDigitLbl)
            setFilledLblProperty(label: fourthDigitLbl)
            setFilledLblProperty(label: fifthDigitLbl)
            setEmptyLblProperty(label: sixthDigitLbl)
        } else if text.characters.count == 6 {
            sixthDigitLbl.text = String(describing: text.characters.last!)
            setFilledLblProperty(label: fristDigitLbl)
            setFilledLblProperty(label: secondDigitLbl)
            setFilledLblProperty(label: thirdDigitLbl)
            setFilledLblProperty(label: fourthDigitLbl)
            setFilledLblProperty(label: fifthDigitLbl)
            setFilledLblProperty(label: sixthDigitLbl)
            sendCode()
        }
    }
    
    func setEmptyLblProperty(label: UILabel) {
        label.text = ""
        label.layer.masksToBounds = true
        label.layer.borderColor = #colorLiteral(red: 0.1607843137, green: 0.1607843137, blue: 0.1607843137, alpha: 1).cgColor
        label.layer.borderWidth = 0.8
        label.layer.cornerRadius = 4.0
    }
    
    func setFilledLblProperty(label: UILabel) {
        label.layer.masksToBounds = true
        label.layer.borderColor = #colorLiteral(red: 0.4980392157, green: 0.9882352941, blue: 0.662745098, alpha: 1).cgColor
        label.layer.borderWidth = 0.8
        label.layer.cornerRadius = 4.0
    }
    
    func setErrorLblProperty(label: UILabel) {
        label.layer.masksToBounds = true
        label.layer.borderColor = #colorLiteral(red: 0.9960784314, green: 0.2196078431, blue: 0.1411764706, alpha: 1).cgColor
        label.layer.borderWidth = 0.8
        label.layer.cornerRadius = 4.0
    }
    
    func showErrorView() {
        moveResendBtnToBottom()
        errorView.isHidden = false
        setErrorLblProperty(label: fristDigitLbl)
        setErrorLblProperty(label: secondDigitLbl)
        setErrorLblProperty(label: thirdDigitLbl)
        setErrorLblProperty(label: fourthDigitLbl)
        setErrorLblProperty(label: fifthDigitLbl)
        setErrorLblProperty(label: sixthDigitLbl)
    }
    
    func hideErrorView() {
        moveResendBtnToTop()
        errorView.isHidden = true
        dummyTextField.text = ""
        setEmptyLblProperty(label: fristDigitLbl)
        setEmptyLblProperty(label: secondDigitLbl)
        setEmptyLblProperty(label: thirdDigitLbl)
        setEmptyLblProperty(label: fourthDigitLbl)
        setEmptyLblProperty(label: fifthDigitLbl)
        setEmptyLblProperty(label: sixthDigitLbl)
    }
    
    func moveResendBtnToBottom() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
            self.resendCodeTCons.constant = 44.0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveResendBtnToTop() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
            self.resendCodeTCons.constant = 14.0
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    @IBAction func actionOnTryAgain(_ sender: UIButton) {
        hideErrorView()
    }
    
    func sendCode() {
        dummyTextField.resignFirstResponder()
        let newPWDVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "CreateNewPWDViewController") as! CreateNewPWDViewController
        newPWDVC.emailID = self.emailID
        newPWDVC.code = self.dummyTextField.text!
        newPWDVC.resetPWDDelegate = self
        self.navigationController?.pushViewController(newPWDVC, animated: true)
        
    }
    
    func verificationCodeError() {
        showErrorView()
    }
    
    func keyboardSize(size: CGSize) {
        self.nextBtnBCons.constant = size.height
        UIView.animate(withDuration: 0.50, animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
}
