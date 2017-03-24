//
//  SplashViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 20/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if (Utils.getUserPool().currentUser()?.isSignedIn)! && Utils.getAllReadyInstalled() {
            login()
        } else {
            Utils.setAllReadyInstalled(value: true)
            Utils.getUserPool().clearLastKnownUser()
            Utils.getUserPool().currentUser()?.signOut()
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.setupAWSCongnito()
            
            Utils.showHomeScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func login() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.isInSplashVC = false
            Utils.getUserDetails(viewController: self)
        } else {
            DispatchQueue.main.async {
                Utils.isInSplashVC = true
                Utils.showAlertForInternetNotReachable(viewController: self)
            }
        }
    }
}
