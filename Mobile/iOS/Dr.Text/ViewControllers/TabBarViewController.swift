//
//  TabBarViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 15/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    // MARK:- UIViewContollers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Utils.getCurrentUser().userRole != "Doctor" {
            self.tabBar.items?[0].title = "Doctors"
            self.viewControllers?.remove(at: 1)
            self.viewControllers?.remove(at: 2)
        } else {
            self.tabBar.items?[0].title = "Patients"
            self.viewControllers?.remove(at: 0)
            self.viewControllers?.remove(at: 3)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK:- UITabBarController Delegate Methods
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected Tab bar item ")
    }
}
