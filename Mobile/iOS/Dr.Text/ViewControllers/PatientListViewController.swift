//
//  PatientListViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 11/01/13.
//  Copyright © 2013 SoftSuave. All rights reserved.
//

import UIKit

class PatientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, patientTableViewCellDelegate,UISearchBarDelegate {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.text = ""
        searchBar.resignFirstResponder()

        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "CombinedShape"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(DoctorsListViewController.actionOnRightBtn(rightBtn:)))
        self.tabBarController?.navigationItem.rightBarButtonItem = barButton;
        
        if searchBar.text!.isEmpty {
            getDoctorPatientList()
        }
    }

    
    func actionOnRightBtn(rightBtn: UIBarButtonItem) {
        
        let invitePatientVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "PatientInvitationViewController")
        navigationController?.pushViewController(invitePatientVC, animated: true)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientTableViewCell", for: indexPath) as! PatientTableViewCell
        
        let phno = conversation.userDetails!.phoneNumber!.replacingOccurrences(of: Utils.user.phCountryCode!, with: "")
        
        cell.nameLbl.text = "\(conversation.userDetails!.firstName!) \(conversation.userDetails!.lastName!)"
        cell.ageLbl.text = "\(Utils.getAgeFromDate(birthday: conversation.userDetails!.dateOfBirth!)) years old"
        cell.phoneNoLbl.text = "\(Utils.formatToPhoneNumber(mobileNumber: phno))"
        
        cell.picImageView.image = #imageLiteral(resourceName: "profilePlaceholder")
        cell.downloadProfilePic(url: conversation.userDetails!.profilePicUrl)
        cell.roomID = conversation.chatRoomId!
        cell.delegate = self
        cell.row = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    
    func chooseLayout() {
        if conversations.count != 0 {
            tableView.isHidden = false
            searchBar.isHidden = false
            noContentView.isHidden = true
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
                        if self.searchBar.text!.isEmpty {
                            self.tableView.reloadData()
                        }
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
    }
}
