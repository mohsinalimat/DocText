//
//  IntroductionViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 10/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSSNS

protocol hideHUDDelegate {
    func hideAllHud();
}

class IntroductionViewController: UIViewController, hideHUDDelegate {
    
    // MARK:- IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var frame: CGRect = CGRect.zero
    var middleLabelStrings:[String] = ["Get answers to any \nhealth question \nanytime, anywhere",
                                       "Ask for a code from\n your doctors. \nIt's safe and secure.",
                                       "Save yourself a trip,\n time and money."]
    
    // MARK:- UIViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        let viewSize = UIScreen.main.bounds.size
        scrollView.frame.size.width  = viewSize.width
        scrollView.frame.size.height = viewSize.height - 164
        
        addScollViewSubviews()
        Utils.hideHUD(view: self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeScrollViewSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    // MARK:- IBAction
    @IBAction func actionOnGetStartedBtn(_ sender: UIButton) {
        let chooseVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ChooseUserTypeViewController") as! ChooseUserTypeViewController
        self.navigationController?.pushViewController(chooseVC, animated: true)
    }
    
    @IBAction func actionOnLoginBtn(_ sender: UIButton) {
        login()
    }
    
    func login() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.introductionViewController = self
            Utils.getUserDetails(viewController: self)
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    @IBAction func actionOnPageChanged(_ sender: UIPageControl) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    
    // MARK:- UIScrollView Delegate Methods
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    
    // MARK:- Other Methods
    func addScollViewSubviews() {
        for index in 0..<middleLabelStrings.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            
            let subView = UIView(frame: frame)
            subView.addSubview(getIntroScreenView(frameSize: frame.size, labelText: middleLabelStrings[index]))
            scrollView.addSubview(subView)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(middleLabelStrings.count), height: scrollView.frame.size.height)
    }
    
    func removeScrollViewSubviews() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
    }
    
    func getIntroScreenView(frameSize: CGSize, labelText: String) -> UIView {
        let view = IntroScreenViewController(frame: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height))
        view.middleLbl.text = labelText
        return view
    }
    
    //Mark:- hideHUDDelegate methods
    func hideAllHud() {
        Utils.hideHUD(view: self.view)
    }
}
