//
//  AlertViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 01/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func dismissButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
