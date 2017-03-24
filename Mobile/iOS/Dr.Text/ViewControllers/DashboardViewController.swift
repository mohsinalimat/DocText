//
//  DashboardViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 10/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSSNS

protocol dashboardProtocolDelegate {
    func actionOnBackButton(lastMessage: Message)
    func actionOnRefresh(conversations: [Conversation])
}

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, dashboardProtocolDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var bottomLbl: UILabel!
    // MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addDocPatLbl: UILabel!
    @IBOutlet weak var addDocORpatientView: UIView!
    @IBOutlet weak var noConvWithDoctors: UIView!
    @IBOutlet weak var noConvWithNoDoctors: UIView!
    @IBOutlet weak var picOutterView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noSearchContentLbl: UILabel!
    @IBOutlet weak var topLbl: UILabel!
    var searchActive : Bool = false
    var filtered: [Conversation] = [Conversation]()
    var conversations: [Conversation] = [Conversation]()
    var timer: Timer?
    
    // MARK:- UIViewContollers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noConvWithDoctors.isHidden = true
        noConvWithNoDoctors.isHidden = true
        tableView.isHidden = true
        searchBar.isHidden = true
        noSearchContentLbl.isHidden = true
        
        if Utils.getCurrentUser().userRole != "Doctor" {
            addDocPatLbl.text = "Add Doctor"
            topLbl.text = "Get your health \nquestions answered \nanytime, anywhere!"
            bottomLbl.text = "First, you need to add a Doctor"
        } else {
            addDocPatLbl.text = "Invite Patient"
            topLbl.text = "Help your patients \nanytime, anywhere"
            bottomLbl.text = "First, you need to invite some patients"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.refreshNotification(notification:)), name: Notification.Name("RefreshDashboardNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.refreshResentMsgNotification(notification:)), name: Notification.Name("DashboardResentMsgNotification"), object: nil)
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkInternetConnection()
        searchBar.text = ""
        searchBar.resignFirstResponder()
        getRooms()
        
        self.navigationController?.isNavigationBarHidden = false
        let rightBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "chatGroup"), style: .plain, target: self, action: #selector(DashboardViewController.actionOnRight(_:)))
        
        self.tabBarController?.navigationItem.rightBarButtonItem = rightBtn;
        
        Utils.sendPendingMessagesToServer()
    }
    
    func addObserver() {
        let notificationName = Notification.Name("UnreadMsgNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.unreadMsgRefresh(notification:)), name: notificationName, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    func refresh(sender: Timer) {
        
        if searchBar.text!.isEmpty {
            getRooms()
        }
    }
    
    
    //MARK:- UITableView Delegates & Data Sources...
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableViewCell", for: indexPath) as! DashboardTableViewCell
        
        let conversation = filtered[indexPath.row]
        cell.contentLabel.text! = conversation.lastMessage!
        cell.dateLabel.text!    = conversation.lastMessageTime!.isEmpty ? "" : Utils.convertDateStringForLastMessage(msString: conversation.lastMessageTime!)
        cell.userImageView.image = #imageLiteral(resourceName: "profilePlaceholder")
        cell.titleLabel.text!   = "\(conversation.userDetails!.firstName!) \(conversation.userDetails!.lastName!)"
        
        cell.adjustContentLblHeight()
        if conversation.unreadCount == 0 {
            cell.picOutterView.isHidden = true
        } else {
            cell.picOutterView.isHidden = false
        }
        cell.downloadProfilePic(url: conversation.convImageUrl)
        
        return cell
    }
    
    func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DashboardTableViewCell
        let chatVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.conversation = filtered[indexPath.row]
        chatVC.receiverImage = cell.userImageView?.image
        chatVC.delegate = self
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
    
    @IBAction func actionOnRight(_ sender: UIBarButtonItem) {
        self.tabBarController?.selectedIndex = 0
    }
    
    
    func actionOnBackButton(lastMessage: Message) {
        for conversation in conversations {
            if conversation.chatRoomId == lastMessage.room_id! {
                conversation.unreadCount = 0
                conversation.lastMessage = lastMessage.message!
                conversation.lastMessageTime =  Utils.millisecondFromDate(dateString: lastMessage.sent_time!)
            }
        }
        
        self.filtered = self.conversations.sorted { (c1, c2) -> Bool in
            if c1.lastMessageTime! > c2.lastMessageTime! {
                return true
            } else {
                return false
            }
        }
        
        tableView.reloadData()
    }
    
    func unreadMsgRefresh(notification: Notification) {
        let dict = notification.object as! NSDictionary
        let lastMessage = dict["lastMessage"] as? Message
        
        for conversation in conversations {
            if conversation.chatRoomId == lastMessage?.room_id! {
                conversation.unreadCount = 1
                conversation.lastMessage = lastMessage?.message!
                conversation.lastMessageTime =  Utils.millisecondFromDate(dateString: (lastMessage?.sent_time!)!)
                
                self.filtered = self.conversations.sorted { (c1, c2) -> Bool in
                    if c1.lastMessageTime! > c2.lastMessageTime! {
                        return true
                    } else {
                        return false
                    }
                }
                
                tableView.reloadData()
            }
        }
    }
    
    func actionOnRefresh(conversations: [Conversation]) {
        self.conversations.removeAll()
        self.conversations = conversations
        self.filtered = self.conversations
        self.tableView.reloadData()
        
        if self.conversations.count == 0 {
            self.showInitialViews(value: 3)
        } else {
            self.showInitialViews(value: 1)
        }
    }
    
    func refreshNotification(notification: Notification) {
        let dict = notification.object as! NSDictionary
        let conversations = dict["conversations"] as? [Conversation]
        
        
        self.conversations.removeAll()
        self.conversations = conversations!
        self.filtered = self.conversations
        self.tableView.reloadData()
        
        if self.conversations.count == 0 {
            self.showInitialViews(value: 3)
        } else {
            self.showInitialViews(value: 1)
        }
    }
    
    func refreshResentMsgNotification(notification: Notification) {
        let dict = notification.object as! NSDictionary
        let lastMsg = dict["lastMessage"] as? Message
        actionOnBackButton(lastMessage: lastMsg!)
    }
    
    func showInitialViews(value: Int) {
        switch value {
        case 1:
            noConvWithDoctors.isHidden = true
            noConvWithNoDoctors.isHidden = true
            tableView.isHidden = false
            searchBar.isHidden = false
            
        case 2:
            noConvWithDoctors.isHidden = false
            noConvWithNoDoctors.isHidden = true
            tableView.isHidden = true
            searchBar.isHidden = true
            
        case 3:
            noConvWithDoctors.isHidden = true
            noConvWithNoDoctors.isHidden = false
            tableView.isHidden = true
            searchBar.isHidden = true
            
        default:
            print("Error found in Selecting view")
        }
    }
    
    @IBAction func actionOnAddDocPatBtn(_ sender: UIButton) {
        if Utils.getCurrentUser().userRole == "Doctor" {
            let invitePatientVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "PatientInvitationViewController")
            navigationController?.pushViewController(invitePatientVC, animated: true)
        } else {
            let verifyDoctorVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "VerifyDoctorViewController") as! VerifyDoctorViewController
            verifyDoctorVC.dashboardelegate = self
            navigationController?.pushViewController(verifyDoctorVC, animated: true)
        }
    }
    
    func getRooms() {
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
                                
                                if let lastMsg = item["lastMessage"] as? String {
                                    conversation.lastMessage = lastMsg
                                } else {
                                    conversation.lastMessage = ""
                                }
                                
                                if let lastMsg = item["lastMessageTime"] as? String {
                                    conversation.lastMessageTime = lastMsg
                                } else {
                                    conversation.lastMessageTime = ""
                                }
                                
                                if let userItem = item["receiverDetails"] as? Dictionary<String, AnyObject> {
                                    conversation.convImageUrl = userItem["ProfilePicUrl"] as? String
                                }
                                
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
                        
                        self.filtered = self.conversations.sorted { (c1, c2) -> Bool in
                            if c1.lastMessageTime! > c2.lastMessageTime! {
                                return true
                            } else {
                                return false
                            }
                        }
                        
                        
                        
                        self.tableView.reloadData()
                        
                        if self.conversations.count == 0 {
                            self.showInitialViews(value: 3)
                        } else {
                            self.showInitialViews(value: 1)
                        }
                        
                        if (self.timer == nil) {
                            self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(DashboardViewController.refresh(sender:)), userInfo: nil, repeats: true)
                        }
                    }
                }
            })
        } else {
            print("Internet is not connected. Calling from Dashboard View controller...")
        }
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
    
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        
        return arr
    }
    
    func checkInternetConnection() {
        if Utils.reachability.currentReachabilityStatus == .notReachable {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
}
