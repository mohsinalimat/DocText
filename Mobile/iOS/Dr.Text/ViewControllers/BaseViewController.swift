//
//  BaseViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 14/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

protocol baseViewControllerProtocolDelegate {
    func keyboardSize(size: CGSize)
}

class BaseViewController: UIViewController {
    
    @IBOutlet weak var nextBtnBCons: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var activeField: UIView!
    var keyboardDelegate: baseViewControllerProtocolDelegate?
    var offSetForKeyboard: CGFloat?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var kbSize = keyboardFrame.size
        
        if (self.keyboardDelegate != nil) {
            self.keyboardDelegate?.keyboardSize(size: kbSize)
        }
        
        if(!(self.activeField != nil)) {
            return
        }
        
        kbSize = CGSize(width: kbSize.width, height: kbSize.height + offSetForKeyboard!)
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        self.scrollView?.contentInset = contentInsets
        self.scrollView?.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= kbSize.height
        if aRect.contains(self.activeField.frame) {
            self.scrollView?.scrollRectToVisible(self.activeField.frame, animated: true)
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        if (self.keyboardDelegate != nil) {
            self.keyboardDelegate?.keyboardSize(size: CGSize.zero)
        }

        if(!(self.activeField != nil)) {
            return
        }
        
        let contentInsets = UIEdgeInsets.zero
        self.scrollView?.contentInset = contentInsets
        self.scrollView?.scrollIndicatorInsets = contentInsets
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    func adjustLayouts() {
        view.layoutIfNeeded()
        view.setNeedsLayout()
    }
    
}
