//
//  DoctorsListViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 30/11/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit


protocol DoctorPatientListProtocolDelegate {
    func actionOnRefreshList(conversations: [Conversation])
}

class DoctorsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, doctorTableViewCellDelegate,DoctorPatientListProtocolDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noSearchContentLbl: UILabel!
    var searchActive : Bool = false
    var conversations: [Conversation] = [Conversation]()
    var filtered: [Conversation] = [Conversation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        noContentView.isHidden = true
        searchBar.isHidden = true
        noSearchContentLbl.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(DoctorsListViewController.refreshNotification(notification:)), name: Notification.Name("RefreshPatientListNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.text = ""
        searchBar.resignFirstResponder()

        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "CombinedShape"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(DoctorsListViewController.actionOnRightBtn(rightBtn:)))
        self.tabBarController?.navigationItem.rightBarButtonItem = barButton;
        
        getDoctorPatientList()
    }
    
    func actionOnRefreshList(conversations: [Conversation]) {
        self.conversations.removeAll()
        self.conversations = conversations
        self.tableView.reloadData()
        self.chooseLayout()
    }
    
    func refreshNotification(notification: Notification) {
        let dict = notification.object as! NSDictionary
        let conversations = dict["conversations"] as? [Conversation]

        self.conversations.removeAll()
        self.conversations = conversations!
        self.tableView.reloadData()
        self.chooseLayout()
    }
    
    func actionOnRightBtn(rightBtn: UIBarButtonItem) {
        
        let verifyDoctorVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "VerifyDoctorViewController") as! VerifyDoctorViewController
        verifyDoctorVC.doctorPatientListdelegate = self
        navigationController?.pushViewController(verifyDoctorVC, animated: true)
    }
    
    //MARK:- UITableView Delegates & Data Sources...
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = self.filtered[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableViewCell", for: indexPath) as! DoctorTableViewCell
        
        if conversation.userDetails?.userRole! == "Patient" {
            cell.doctorNameLbl.text = "\(conversation.userDetails!.firstName!) \(conversation.userDetails!.lastName!)"
            cell.doctorAddrLbl.text = "DOB: \(conversation.userDetails!.dateOfBirth!)"
            cell.doctorTypeLbl.text = ""
            cell.adjustAddressLblHeight()
        } else {
            cell.doctorNameLbl.text = "Dr. \(conversation.userDetails!.firstName!) \(conversation.userDetails!.lastName!)"
            cell.doctorAddrLbl.text = "\(conversation.userDetails!.doctor_addr_street!), \(conversation.userDetails!.doctor_addr_unit!), \(conversation.userDetails!.doctor_addr_city!), \(conversation.userDetails!.doctor_addr_state!), \(conversation.userDetails!.doctor_addr_zip!)"
            cell.doctorTypeLbl.text = conversation.userDetails!.doctorType!
        }
        
        cell.picImageView.image = #imageLiteral(resourceName: "profilePlaceholder")
        cell.downloadProfilePic(url: conversation.userDetails!.profilePicUrl)
        cell.roomID = conversation.chatRoomId!
        cell.adjustContentLblHeight()
        cell.delegate = self
        cell.row = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let conversation = self.filtered[indexPath.row]
        if conversation.userDetails?.userRole! == "Patient" {
            return 240
        } else {
            return 265
        }
    }
    
    func chooseLayout() {
        if conversations.count != 0 {
            tableView.isHidden = false
            noContentView.isHidden = true
            searchBar.isHidden = false
        } else {
            tableView.isHidden = true
            searchBar.isHidden = true
            noContentView.isHidden = false
        }
    }
    
    
    func getDoctorPatientList() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            DocTextApi.getRooms(senderId: Utils.getCurrentUser().emailID!, completionHandler: { (dict, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        print("Error occured")
                    } else {
                        self.conversations.removeAll()
                        self.filtered.removeAll()
                        
                        if let dictItems = dict {
                            for item in dictItems {
                                let conversation = Conversation()
                                conversation.roomName = item["roomName"] as? String
                                conversation.chatRoomId = item["room_id"] as? String
                                conversation.patientId = item["patientId"] as? String
                                conversation.doctorId = item["doctorId"] as? String
                                conversation.patientName = item["patientName"] as? String
                                conversation.doctorName = item["doctorName"] as? String
                                conversation.unreadCount = item["unreadCount"] as? Int
                                
                                if let userItem = item["receiverDetails"] as? Dictionary<String, AnyObject> {
                                    let user = User()
                                    user.emailID = userItem["Email"] as? String
                                    user.doctorTitle = userItem["DoctorTitle"] as? String
                                    user.doctorType = userItem["DoctorType"] as? String
                                    user.doctor_addr_city = userItem["Doctor_Addr_City"] as? String
                                    user.doctor_addr_state = userItem["Doctor_Addr_State"] as? String
                                    user.doctor_addr_street = userItem["Doctor_Addr_Street"] as? String
                                    user.doctor_addr_unit = userItem["Doctor_Addr_Unit"] as? String
                                    user.doctor_addr_zip = userItem["Doctor_Addr_Zip"] as? String
                                    user.firstName = userItem["FirstName"] as? String
                                    user.lastName = userItem["LastName"] as? String
                                    user.phoneNumber = userItem["PhoneNo"] as? String
                                    user.profilePicUrl = userItem["ProfilePicUrl"] as? String
                                    user.userRole = userItem["UserRole"] as? String
                                    user.dateOfBirth = userItem["dob"] as? String
                                    conversation.userDetails = user
                                }
                                self.conversations.append(conversation)
                            }
                        }
                        self.filtered = self.conversations
                        self.tableView.reloadData()
                        self.chooseLayout()
                    }
                }
            })
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    //MARK:// doctorTableViewCellDelegate Method
    func actionOnSendText(btn: UIButton, indexPath: Int, userImg: UIImage) {
        let chatVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.conversation = filtered[indexPath]
        chatVC.receiverImage = userImg
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    //MARK: UISearchbar delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        noSearchContentLbl.isHidden = true
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered.removeAll()
        filtered = conversations.filter({ (conversation) -> Bool in
            let tmp: NSString = "\(conversation.userDetails!.firstName!) \(conversation.userDetails!.lastName!)" as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        if searchText == "" {
            self.filtered = self.conversations
            self.tableView.reloadData()
            searchBar.resignFirstResponder()
        }
        
        if(filtered.count == 0){
            searchActive = false;
            noSearchContentLbl.isHidden = false
        } else {
            noSearchContentLbl.isHidden = true
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        noSearchContentLbl.isHidden = true
    }
}
