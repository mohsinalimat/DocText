//
//  DoctorPromptListViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 09/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

protocol promptListDelegate {
    func selectedItem(type: String, index: Int)
}

class DoctorPromptListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    var selecteditemIndex: Int?
    var type: String?
    var itemList = [String]()
    var promptDelegate: promptListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
    }
    
    //MARK:- UITableview delegate and data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocPromptTableViewCell", for: indexPath) as! DocPromptTableViewCell
        cell.contentLbl.text = itemList[indexPath.row]
        
        if let index = selecteditemIndex, index == indexPath.row {
            cell.checkBoxLbl.isHidden = false
        } else {
            cell.checkBoxLbl.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (promptDelegate != nil) {
            promptDelegate?.selectedItem(type: type!, index: indexPath.row)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK:- Other Methods
    func setBackButton() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackChevron") , style: .plain, target: self, action: #selector(BaseViewController.actionOnBackBtn(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    
    func actionOnBackBtn(sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
}
