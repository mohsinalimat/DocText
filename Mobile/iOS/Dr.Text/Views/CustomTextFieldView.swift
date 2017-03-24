 //
//  CustomTextFieldView.swift
//  Dr.Text
//
//  Created by SoftSuave on 28/11/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

protocol customTextFieldProtocol {
    func beginTextFieldEditing(textField: UITextField)
    func endTextFieldEditing(textField: UITextField)
    func shouldReturnTextField(textField: UITextField)
    func editingChangedTextField(textField: UITextField)
    func shouldChangeCharactersInTextField(textField: UITextField, range: NSRange, replaceString: String) -> Bool
    func actionOnClearBtn(btn: UIButton)
}

class CustomTextFieldView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var floatingLblLCons: NSLayoutConstraint!
    @IBOutlet weak var floatingLblTCons: NSLayoutConstraint!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var floatingLbl: UILabel!
    @IBOutlet weak var bottomLineLbl: UILabel!
    var customTextfieldDelegate: customTextFieldProtocol! = nil
    var isPassowrdField = false
    var placeHolderText = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
        floatingLblConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
        floatingLblConfig()
    }
    
    private func nibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
    
    func floatingLblConfig() {
        textField.setLeftPaddingPoints(10)
        textField.addTarget(self, action: #selector(CustomTextFieldView.textFieldEditingChanged(textField:)), for: .editingChanged)
        floatingLbl.alpha = 0.0
        floatingLblTCons.constant = 22
        floatingLblLCons.constant = 10
        floatingLbl.font = UIFont.systemFont(ofSize: 17.0)
        adjustLayouts()
    }
    
    func adjustLayouts() {
        view.layoutIfNeeded()
        view.setNeedsLayout()
    }
    
    // MARK:- UITextField Delegate Methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if customTextfieldDelegate != nil {
            self.customTextfieldDelegate.shouldReturnTextField(textField: textField)
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        textField.placeholder = nil
        showAnimation()
        
        if customTextfieldDelegate != nil {
            self.customTextfieldDelegate.beginTextFieldEditing(textField: textField)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            hideAnimation()
        } else {
            removeSelectedConfig()
        }
        
        if customTextfieldDelegate != nil {
            self.customTextfieldDelegate.endTextFieldEditing(textField: textField)
        }
    }
    
    func textFieldEditingChanged(textField: UITextField) {
        
        if customTextfieldDelegate != nil {
            self.customTextfieldDelegate.editingChangedTextField(textField: textField)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if customTextfieldDelegate != nil {
            return self.customTextfieldDelegate.shouldChangeCharactersInTextField(textField: textField, range: range, replaceString: string)
        }
        
        return true
    }
    
    func showAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
            self.floatingLblTCons.constant = 0
            self.floatingLblLCons.constant = 0
            self.floatingLbl.alpha = 1.0
            self.addSelectedConfig()
            self.adjustLayouts()
            self.bottomLineLbl.isHidden = true
        }, completion: { (bool) in
            if !self.isPassowrdField {
                self.showClearBtn()
            } else {
                self.addShowTextViewInPassword()
            }
        })
    }
    
    func hideAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
            self.floatingLblTCons.constant = 22
            self.floatingLblLCons.constant = 10
            self.floatingLbl.alpha = 0.0
            self.bottomLineLbl.isHidden = false
            self.textField.backgroundColor = UIColor.clear
            self.textField.layer.borderColor = UIColor.clear.cgColor
            self.textField.layer.borderWidth = 0.0
            self.adjustLayouts()
        }, completion:  { (bool) in
            self.textField.placeholder = self.placeHolderText
        })
    }
    
    func showTextFieldWithText() {
        self.floatingLblTCons.constant = 0
        self.floatingLblLCons.constant = 0
        self.floatingLbl.alpha = 1.0
        self.addSelectedConfig()
        self.adjustLayouts()
        self.bottomLineLbl.isHidden = true
        textField.layer.borderWidth = 0.0
    }
    
    func hideTextFieldWithText() {
        self.floatingLblTCons.constant = 22
        self.floatingLblLCons.constant = 10
        self.floatingLbl.alpha = 0.0
        self.bottomLineLbl.isHidden = false
        self.textField.backgroundColor = UIColor.clear
        self.textField.layer.borderColor = UIColor.clear.cgColor
        self.textField.layer.borderWidth = 0.0
        self.adjustLayouts()
        self.textField.placeholder = self.placeHolderText
    }
    
    func addSelectedConfig() {
        textField.layer.masksToBounds = true
        textField.layer.borderColor = #colorLiteral(red: 0.9882352941, green: 0.8, blue: 0.2823529412, alpha: 1).cgColor
        textField.layer.borderWidth = 1.0
        textField.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
    }
    
    func errorConfiguration() {
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0.0
        textField.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.2196078431, blue: 0.1411764706, alpha: 0.2)
    }
    
    func removeSelectedConfig() {
        textField.layer.borderWidth = 0.0
    }
    
    func showPositiveIndicator() {
        let positiveIndication = UIImageView(image: #imageLiteral(resourceName: "Oval"))
        if let size = positiveIndication.image?.size {
            positiveIndication.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        positiveIndication.contentMode = UIViewContentMode.center
        self.textField.rightView = positiveIndication
        self.textField.rightViewMode = UITextFieldViewMode.always
    }
    
    func showClearBtn() {
        let image = #imageLiteral(resourceName: "TextFieldClearBtn")
        let button   = UIButton(type: UIButtonType.custom) as UIButton
        button.imageView?.contentMode = .center
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(CustomTextFieldView.showClearBtnActionTouchUpInside(btn:)), for: .touchUpInside)
        button.frame = CGRect(x: 0.0, y: 0.0, width: image.size.width + 10.0, height: image.size.height)
        self.textField.rightView = button
        self.textField.rightViewMode = UITextFieldViewMode.always
    }
    
    func showClearBtnActionTouchUpInside(btn: UIButton) {
        self.textField.text = ""
        if customTextfieldDelegate != nil {
             self.customTextfieldDelegate.actionOnClearBtn(btn: btn)
        }
    }
    
    func hidePositiveIndicator() {
        self.textField.rightView = UIView()
    }
    
    func addShowTextViewInPassword() {
        let image = #imageLiteral(resourceName: "viewPwdShow")
        let button   = UIButton(type: UIButtonType.custom) as UIButton
        button.imageView?.contentMode = .center
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(CustomTextFieldView.showPWDActionTouchUpInside(btn:)), for: .touchUpInside)
        button.frame = CGRect(x: 0.0, y: 0.0, width: image.size.width + 10.0, height: image.size.height)
        self.textField.rightView = button
        self.textField.rightViewMode = UITextFieldViewMode.always
        
        if !self.textField.isSecureTextEntry {
            button.setImage(#imageLiteral(resourceName: "viewPwdHide"), for: .normal)
        } else {
            button.setImage(#imageLiteral(resourceName: "viewPwdShow"), for: .normal)
        }
    }
    
    func showPWDActionTouchUpInside(btn: UIButton) {
        if self.textField.isSecureTextEntry {
            self.textField.isSecureTextEntry = false
            btn.setImage(#imageLiteral(resourceName: "viewPwdHide"), for: .normal)
        } else {
            self.textField.isSecureTextEntry = true
            btn.setImage(#imageLiteral(resourceName: "viewPwdShow"), for: .normal)
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    open override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        if ((action == #selector(UIResponderStandardEditActions.paste(_:)) || (action == #selector(UIResponderStandardEditActions.cut(_:))))) {
            return nil
        }
        return super.target(forAction: action, withSender: sender)
    }
}
