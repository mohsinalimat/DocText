//
//  paymentViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 14/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class paymentViewController: BaseViewController, customTextFieldProtocol, customDatePickerDelegate, baseViewControllerProtocolDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var cardNoErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var cardNoErrorView: UIView!
    @IBOutlet weak var cardNoErrorLbl: UILabel!
    
    @IBOutlet weak var expDateErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var expDateErrorView: UIView!
    @IBOutlet weak var expDateErrorLbl: UILabel!
    
    @IBOutlet weak var cvvNoErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var cvvNoErrorView: UIView!
    @IBOutlet weak var cvvNoErrorLbl: UILabel!
    
    @IBOutlet weak var zipCodeErrorHCons: NSLayoutConstraint!
    @IBOutlet weak var zipCodeErrorView: UIView!
    @IBOutlet weak var zipCodeErrorLbl: UILabel!
    
    @IBOutlet weak var cardNoTextFieldView: CustomTextFieldView!
    @IBOutlet weak var expDateTextFieldView: CustomTextFieldView!
    @IBOutlet weak var cvvNoTextFieldView: CustomTextFieldView!
    @IBOutlet weak var zipCodeTextFieldView: CustomTextFieldView!
    @IBOutlet weak var addCardBtn: UIButton!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!

    var picker = DatePickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setTapGesture()
        
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        picker.custompickerDelegate = self
        picker.minYear = year
        picker.maxYear = 2100
        picker.rowHeight = 40
        
        picker.selectToday()
        picker.selectRow(4, inComponent: 1, animated: false)
        picker.selectRow(500, inComponent: 0, animated: false)
        
        cardNoTextFieldView.customTextfieldDelegate = self
        cardNoTextFieldView.textField.placeholder = "Card Number"
        cardNoTextFieldView.floatingLbl.text = "Card Number"
        cardNoTextFieldView.textField.keyboardType = .phonePad
        cardNoTextFieldView.textField.keyboardAppearance = .default
        
        expDateTextFieldView.customTextfieldDelegate = self
        expDateTextFieldView.textField.placeholder = "Expiration Date"
        expDateTextFieldView.floatingLbl.text = "Expiration Date"
        expDateTextFieldView.textField.inputView = picker
        
        cvvNoTextFieldView.customTextfieldDelegate = self
        cvvNoTextFieldView.textField.placeholder = "CVV"
        cvvNoTextFieldView.floatingLbl.text = "CVV"
        cvvNoTextFieldView.textField.keyboardType = .phonePad
        cvvNoTextFieldView.textField.keyboardAppearance = .default
        
        zipCodeTextFieldView.customTextfieldDelegate = self
        zipCodeTextFieldView.textField.placeholder = "Zip Code"
        zipCodeTextFieldView.floatingLbl.text = "Zip Code"
        zipCodeTextFieldView.textField.keyboardType = .numberPad
        zipCodeTextFieldView.textField.keyboardAppearance = .default
        
        showFrontCardImage(cardType: 0)
        hideAllErrorView()
        self.activeField = cardNoTextFieldView.textField
        
        
        let rightBarButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(paymentViewController.actionDeleteCared))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardDelegate = self
        showCardDetails()
        validateDeleteBtn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = (self.scrollView?.frame.height)!
        containerViewWCons.constant = (self.scrollView?.frame.width)!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cardNoTextFieldView.textField.resignFirstResponder()
        expDateTextFieldView.textField.resignFirstResponder()
        cvvNoTextFieldView.textField.resignFirstResponder()
        zipCodeTextFieldView.textField.resignFirstResponder()
    }
    
    public func validateNextBtnStatus() {
        cardNoTextFieldView.textField.resignFirstResponder()
        expDateTextFieldView.textField.resignFirstResponder()
        cvvNoTextFieldView.textField.resignFirstResponder()
        zipCodeTextFieldView.textField.resignFirstResponder()
        
        if (cardNoTextFieldView.textField.text?.isEmpty)! {
            showErrorMsgView(customTextFieldview: cardNoTextFieldView, message: EMPTY_CARD_NO)
        } else if (expDateTextFieldView.textField.text?.isEmpty)! {
            showErrorMsgView(customTextFieldview: expDateTextFieldView, message: EMPTY_EXP_DATE)
        } else if (cvvNoTextFieldView.textField.text?.isEmpty)!  {
            showErrorMsgView(customTextFieldview: cvvNoTextFieldView, message: EMPTY_CVV)
        } else if (zipCodeTextFieldView.textField.text?.isEmpty)! {
            showErrorMsgView(customTextFieldview: zipCodeTextFieldView, message: EMPTY_ZIP)
        } else if (zipCodeTextFieldView.textField.text?.characters.count != 5) && (zipCodeTextFieldView.textField.text?.characters.count != 12) {
            showErrorMsgView(customTextFieldview: zipCodeTextFieldView, message: ZIP_NOT_VALID)
        } else {
            if Utils.user.cardId! != "nil" {
                updateCard()
            } else {
                addCard()
            }
        }
    }
    
    func didCustomDatePickerSelectRow(date: String) {
        expDateTextFieldView.textField.text = date
    }
    
    func showFrontCardImage(cardType: Int) {
        let positiveIndication = UIImageView()
        
        switch cardType {
        case 0:
            positiveIndication.image = #imageLiteral(resourceName: "emptyCardImg")
        case 1:
            positiveIndication.image = #imageLiteral(resourceName: "American Express")
        case 2:
            positiveIndication.image = #imageLiteral(resourceName: "Visa")
        case 3:
            positiveIndication.image = #imageLiteral(resourceName: "MasterCard")
        case 4:
            positiveIndication.image = #imageLiteral(resourceName: "Maestro")
        case 5:
            positiveIndication.image = #imageLiteral(resourceName: "JCB")
        case 6:
            positiveIndication.image = #imageLiteral(resourceName: "Discover")
        case 7:
            positiveIndication.image = #imageLiteral(resourceName: "Diners Club")
            
        default:
            print("Error found")
        }
        
        if let size = positiveIndication.image?.size {
            positiveIndication.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        positiveIndication.contentMode = UIViewContentMode.scaleAspectFit
        cardNoTextFieldView.textField.leftView = positiveIndication
        cardNoTextFieldView.textField.leftViewMode = UITextFieldViewMode.always
    }
    
    func showBackBarCodeImage() {
        let positiveIndication = UIImageView(image: #imageLiteral(resourceName: "barCode"))
        if let size = positiveIndication.image?.size {
            positiveIndication.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        positiveIndication.contentMode = UIViewContentMode.center
        cardNoTextFieldView.textField.rightView = positiveIndication
        cardNoTextFieldView.textField.rightViewMode = UITextFieldViewMode.always
    }
    
    //MARK:- customTextFieldProtocol Methods
    func beginTextFieldEditing(textField: UITextField) {
        self.offSetForKeyboard = 35.0
        self.activeField = textField
        
        if cardNoTextFieldView.textField == textField {
            cardNoTextFieldView.placeHolderText = "Card Number"
            cardNoTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: cardNoTextFieldView)
        } else if expDateTextFieldView.textField == textField {
            expDateTextFieldView.placeHolderText = "Expiration Date"
            expDateTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: expDateTextFieldView)
        } else if cvvNoTextFieldView.textField == textField {
            cvvNoTextFieldView.placeHolderText = "CVV"
            cvvNoTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: cvvNoTextFieldView)
        } else if zipCodeTextFieldView.textField == textField {
            zipCodeTextFieldView.placeHolderText = "Zip Code"
            zipCodeTextFieldView.hidePositiveIndicator()
            hideErrorMsgView(customTextFieldview: zipCodeTextFieldView)
        }
    }
    
    func endTextFieldEditing(textField: UITextField) {
    }
    
    func shouldReturnTextField(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func editingChangedTextField(textField: UITextField) {
        if textField == cardNoTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: cardNoTextFieldView)
            cardNoTextFieldView.addSelectedConfig()
            setCardTypeImage(textField: textField)
        } else if textField == expDateTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: expDateTextFieldView)
            expDateTextFieldView.addSelectedConfig()
        } else if textField == cvvNoTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: cvvNoTextFieldView)
            cvvNoTextFieldView.addSelectedConfig()
        } else if textField == zipCodeTextFieldView.textField {
            hideErrorMsgView(customTextFieldview: zipCodeTextFieldView)
            zipCodeTextFieldView.addSelectedConfig()
        }
    }
    
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool {
        
        if cardNoTextFieldView.textField == textField {
            if (textField.text?.characters.count)! >= 19 {
                if(range.length == 0) {
                    return false
                }
            }
            
            if (textField.text?.characters.count)! == 4 || (textField.text?.characters.count)! == 9 || (textField.text?.characters.count)! == 14 {
                textField.text = textField.text! + " "
            }
            
            if (textField.text?.characters.count)! == 5 || (textField.text?.characters.count)! == 10 || (textField.text?.characters.count)! == 15 {
                if(range.length > 0) {
                    let fromIndex = textField.text!.index(before: textField.text!.index(textField.text!.endIndex, offsetBy: 0))
                    textField.text = textField.text!.substring(to: fromIndex)
                }
            }
        } else if cvvNoTextFieldView.textField == textField {
            if (textField.text?.characters.count)! >= 4 {
                if(range.length == 0) {
                    return false
                }
            }
            
        }  else if zipCodeTextFieldView.textField == textField {
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
        }
        return true
    }
    
    func actionOnClearBtn(btn: UIButton) {
    }
    
    @IBAction func actionOnAddCard(_ sender: UIButton) {
        validateNextBtnStatus()
    }
    
    func showCardDetails() {
        if Utils.user.cardId! != "nil" && Utils.user.iSCardWorking {
            cardNoTextFieldView.textField.text = "xxxx xxxx xxxx \(Utils.user.cardLastFourDigit!)"
            cardNoTextFieldView.isUserInteractionEnabled = false
            cardNoTextFieldView.showTextFieldWithText()
            expDateTextFieldView.textField.text = "\(Utils.user.cardExpMonth!)/\(Utils.user.cardExpYear!)"
            expDateTextFieldView.showTextFieldWithText()
            zipCodeTextFieldView.textField.text = Utils.user.cardZipCode!
            zipCodeTextFieldView.showTextFieldWithText()
            addCardBtn.setTitle("Update card", for: .normal)
            
            if (Utils.user.cardBrand?.contains("Visa"))! {
                showFrontCardImage(cardType: 2)
            } else if  Utils.user.cardBrand == "MasterCard" {
                showFrontCardImage(cardType: 3)
            }  else if  Utils.user.cardBrand == "American Express" {
                showFrontCardImage(cardType: 1)
            } else if  Utils.user.cardBrand == "Maestro" {
                showFrontCardImage(cardType: 4)
            } else if  Utils.user.cardBrand == "JCB" {
                showFrontCardImage(cardType: 5)
            } else if  Utils.user.cardBrand == "Discover" {
                showFrontCardImage(cardType: 6)
            } else if  Utils.user.cardBrand == "Diners Club" {
                showFrontCardImage(cardType: 7)
            }
            else{
                showFrontCardImage(cardType: 0)
            }
        }
    }
    
    func addCard() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view.window!)
            
            let arr = expDateTextFieldView.textField.text!.components(separatedBy: "/")
            let expMonth = arr[0]
            let expYear = arr[1]
            
            var customerID = ""
            if Utils.user.customerId! != "nil" {
                customerID = Utils.user.customerId!
            } else {
                customerID = ""
            }
            
            DocTextApi.createStripeCustomer(customerId: customerID, expMonth: expMonth, expYear: expYear, card_number: cardNoTextFieldView.textField.text!, cvc: cvvNoTextFieldView.textField.text!, zipCode: zipCodeTextFieldView.textField.text!, completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        Utils.hideHUD(view: self.view.window!)
                        Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                    } else {
                        let status = result!["success"] as? Int
                        if status != nil && status == 1 {
                            let customerID = result!["customerId"] as? String
                            let cardID = result!["cardId"] as? String
                            
                            let customerIDAttribute = AWSCognitoIdentityUserAttributeType()
                            customerIDAttribute?.name  = "custom:CustomerId"
                            customerIDAttribute?.value = customerID!
                            
                            let cardIDAttribute = AWSCognitoIdentityUserAttributeType()
                            cardIDAttribute?.name  = "custom:CardId"
                            cardIDAttribute?.value = cardID!
                            
                            Utils.getUserPool().currentUser()?.update([customerIDAttribute!, cardIDAttribute!]).continue({ (task) -> Any? in
                                DispatchQueue.main.async {
                                    Utils.hideHUD(view: self.view.window!)
                                    if task.error != nil {
                                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                                        print(((task.error as! NSError).userInfo["message"] as? String)!)
                                        Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                                    } else {
                                        print("success")
                                        Utils.user.customerId = customerID!
                                        Utils.user.cardId = cardID!
                                        Utils.user.cardExpMonth = Int(expMonth)
                                        Utils.user.cardExpYear = Int(expYear)
                                        Utils.user.cardZipCode = self.zipCodeTextFieldView.textField.text!
                                        Utils.user.cardLastFourDigit = String(self.cardNoTextFieldView.textField.text!.characters.suffix(4))
                                        if Utils.user.cardId! != "nil" {
                                            Utils.getCardDetails(viewController: self, from: "PaymentViewController")
                                        } else {
                                            print("Error found")
                                        }
                                        self.validateDeleteBtn()
                                    }
                                }
                                return nil
                            })
                        } else {
                            Utils.hideHUD(view: self.view.window!)
                            Utils.showAlert(title: "Error", message: "Something went wrong...", viewController: self)
                        }
                    }
                }
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    func updateCard() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.showHUD(view: self.view.window!)
            
            let arr = expDateTextFieldView.textField.text!.components(separatedBy: "/")
            let expMonth = arr[0]
            let expYear = arr[1]
            
            DocTextApi.updateCardDetails(zipCode: zipCodeTextFieldView.textField.text!, expMonth: expMonth, expYear: expYear, completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        Utils.hideHUD(view: self.view.window!)
                        Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                    } else {
                        let status = result!["success"] as? Int
                        if status != nil && status == 1 {
                            
                            let card = result!["card"] as? Dictionary<(String),(Any)>
                            Utils.user.customerId = card!["customer"] as? String
                            Utils.user.cardId = card!["id"] as? String
                            Utils.user.cardBrand = card!["brand"] as? String
                            Utils.user.cardLastFourDigit = card!["last4"] as? String
                            Utils.user.cardExpMonth = card!["exp_month"] as? Int
                            Utils.user.cardExpYear = card!["exp_year"] as? Int
                            Utils.user.cardZipCode = card!["address_zip"] as? String
                            
                            let customerIDAttribute = AWSCognitoIdentityUserAttributeType()
                            customerIDAttribute?.name  = "custom:CustomerId"
                            customerIDAttribute?.value = Utils.user.customerId!
                            
                            let cardIDAttribute = AWSCognitoIdentityUserAttributeType()
                            cardIDAttribute?.name  = "custom:CardId"
                            cardIDAttribute?.value = Utils.user.cardId!
                            
                            Utils.getUserPool().currentUser()?.update([customerIDAttribute!, cardIDAttribute!]).continue({ (task) -> Any? in
                                DispatchQueue.main.async {
                                    Utils.hideHUD(view: self.view.window!)
                                    if task.error != nil {
                                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                                        print(((task.error as! NSError).userInfo["message"] as? String)!)
                                        Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                                    } else {
                                        print("success")
                                        self.validateDeleteBtn()
                                        if Utils.user.cardId! != "nil" {
                                            Utils.getCardDetails(viewController: self, from: "PaymentViewController")
                                        } else {
                                            print("Error found")
                                        }
                                    }
                                }
                                return nil
                            })
                        } else {
                            Utils.hideHUD(view: self.view.window!)
                            if let message = result?["message"] as? String {
                                Utils.showAlert(title: "Error Found", message: message, viewController:  self)
                            } else {
                                Utils.showAlert(title: "Error Found", message: "Something went wrong!", viewController: self)
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
        if customTextFieldview == cardNoTextFieldView {
            cardNoErrorView.isHidden = false
            cardNoErrorHCons.constant = 40
            cardNoErrorLbl.text = message
            cardNoTextFieldView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == expDateTextFieldView {
            expDateErrorView.isHidden = false
            expDateErrorHCons.constant = 40
            expDateErrorLbl.text = message
            expDateTextFieldView.errorConfiguration()
            adjustLayouts()
        } else if customTextFieldview == cvvNoTextFieldView {
            cvvNoErrorView.isHidden = false
            cvvNoErrorHCons.constant = 40
            cvvNoErrorLbl.text = message
            cvvNoTextFieldView.errorConfiguration()
            adjustLayouts()
        } else {
            zipCodeErrorView.isHidden = false
            zipCodeErrorHCons.constant = 40
            zipCodeErrorLbl.text = message
            zipCodeTextFieldView.errorConfiguration()
            adjustLayouts()
        }
    }
    
    func hideErrorMsgView(customTextFieldview: CustomTextFieldView) {
        if customTextFieldview == cardNoTextFieldView {
            cardNoErrorView.isHidden = true
            cardNoErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == expDateTextFieldView {
            expDateErrorView.isHidden = true
            expDateErrorHCons.constant = 0
            adjustLayouts()
        } else if customTextFieldview == cvvNoTextFieldView {
            cvvNoErrorView.isHidden = true
            cvvNoErrorHCons.constant = 0
            adjustLayouts()
        } else {
            zipCodeErrorView.isHidden = true
            zipCodeErrorHCons.constant = 0
            adjustLayouts()
        }
    }
    
    func hideAllErrorView() {
        hideErrorMsgView(customTextFieldview: cardNoTextFieldView)
        hideErrorMsgView(customTextFieldview: expDateTextFieldView)
        hideErrorMsgView(customTextFieldview: cvvNoTextFieldView)
        hideErrorMsgView(customTextFieldview: zipCodeTextFieldView)
    }
    
    func setCardTypeImage(textField: UITextField) {
        if textField.text!.characters.count >= 1 && getSubstring(str: textField.text!, count: 1) == "4"{
            showFrontCardImage(cardType: 2)
        } else if textField.text!.characters.count >= 2 && (getSubstring(str: textField.text!, count: 2) == "34" || getSubstring(str: textField.text!, count: 2) == "37"){
            showFrontCardImage(cardType: 1)
        } else if textField.text!.characters.count >= 2 && (getSubstring(str: textField.text!, count: 2) == "60" || getSubstring(str: textField.text!, count: 2) == "65"){
            showFrontCardImage(cardType: 6)
        } else if textField.text!.characters.count >= 2 && (getSubstring(str: textField.text!, count: 2) == "51"  ||
            getSubstring(str: textField.text!, count: 2) == "52" ||
            getSubstring(str: textField.text!, count: 2) == "53" ||
            getSubstring(str: textField.text!, count: 2) == "54" ||
            getSubstring(str: textField.text!, count: 2) == "55"){
            showFrontCardImage(cardType: 3)
        } else if textField.text!.characters.count >= 2 && (getSubstring(str: textField.text!, count: 2) == "30"  ||
            getSubstring(str: textField.text!, count: 2) == "38") {
            showFrontCardImage(cardType: 7)
        } else if textField.text!.characters.count >= 3 && (getSubstring(str: textField.text!, count: 3) == "305" ||
            getSubstring(str: textField.text!, count: 3) == "300") {
            showFrontCardImage(cardType: 7)
        } else if textField.text!.characters.count >= 2 && (getSubstring(str: textField.text!, count: 2) == "35" ) {
            showFrontCardImage(cardType: 5)
        } else if textField.text!.characters.count >= 4 && (getSubstring(str: textField.text!, count: 4) == "2131" ||
            getSubstring(str: textField.text!, count: 4) == "1800") {
            showFrontCardImage(cardType: 5)
        } else if textField.text!.characters.count >= 4 && ( getSubstring(str: textField.text!, count: 4)  == "5018"  ||
            getSubstring(str: textField.text!, count: 4) == "5020" ||
            getSubstring(str: textField.text!, count: 4) == "5038" ||
            getSubstring(str: textField.text!, count: 4) == "5893" ||
            getSubstring(str: textField.text!, count: 4) == "6304" ||
            getSubstring(str: textField.text!, count: 4) == "6759" ||
            getSubstring(str: textField.text!, count: 4) == "6761" ||
            getSubstring(str: textField.text!, count: 4) == "6762" ||
            getSubstring(str: textField.text!, count: 4) == "6763"){
            showFrontCardImage(cardType: 4)
        } else {
            showFrontCardImage(cardType: 0)
        }
    }
    
    func getSubstring(str: String, count: Int) -> String {
        return str.substring(to: str.characters.index(str.startIndex, offsetBy: count))
    }
    
    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChangePWDViewController.actionOnTapGesture(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func actionOnTapGesture(sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    func actionDeleteCared() {
        cardNoTextFieldView.textField.resignFirstResponder()
        expDateTextFieldView.textField.resignFirstResponder()
        cvvNoTextFieldView.textField.resignFirstResponder()
        zipCodeTextFieldView.textField.resignFirstResponder()

        let alertController = UIAlertController(title: "", message: "Do you want to delete a card?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("you have pressed the Cancel button");
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction!) in
            Utils.showHUD(view: self.view.window!)
            let customerIDAttribute = AWSCognitoIdentityUserAttributeType()
            customerIDAttribute?.name  = "custom:CustomerId"
            customerIDAttribute?.value = "nil"
            
            let cardIDAttribute = AWSCognitoIdentityUserAttributeType()
            cardIDAttribute?.name  = "custom:CardId"
            cardIDAttribute?.value = "nil"
            
            Utils.getUserPool().currentUser()?.update([customerIDAttribute!, cardIDAttribute!]).continue({ (task) -> Any? in
                DispatchQueue.main.async {
                    Utils.hideHUD(view: self.view.window!)
                    if task.error != nil {
                        print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                        print(((task.error as! NSError).userInfo["message"] as? String)!)
                        Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: self)
                    } else {
                        print("success")
                        self.validateDeleteBtn()
                        Utils.user.cardId! = "nil"
                        Utils.user.customerId! = "nil"
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
                return nil
            })
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func validateDeleteBtn() {
        if Utils.user.cardId! == "nil" {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}
