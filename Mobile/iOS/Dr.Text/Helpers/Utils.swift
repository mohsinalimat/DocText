//
//  Utils.swift
//  Dr.Text
//
//  Created by SoftSuave on 10/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import MBProgressHUD
import CoreTelephony
import AWSSNS
import SDWebImage
import ReachabilitySwift
import AWSS3

class Utils: NSObject {
    
    static var user: User!
    static var deviceToken: String?
    static var signupObj = signUp()
    static let messageDA = MessageDA()
    static let appdelegate = UIApplication.shared.delegate as! AppDelegate
    static let chatRefreshNotification = Notification.Name("Refresh_Chat_Notification")
    static var isUnsentMessageProcessing = false
    static var isUploadingProfilePicProcessing = false
    static let reachability = Reachability()!
    static var notification: CWStatusBarNotification?
    static var isInSplashVC = false
    static var currentChatMessages = [Message]()
   
    // MARK:- StoryBoard Instance
    class func getStoryBoard() -> UIStoryboard {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        return storyBoard
    }
    
    // MARK:- Phone Number Formatter Methods
    class func getLength(mobileNumber: String) -> Int {
        var mobileNumber = mobileNumber
        mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
        
        return mobileNumber.characters.count
    }
    
    class func formatNumber(mobileNumber: String) -> String {
        var mobileNumber = mobileNumber
        mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "")
        
        let length = mobileNumber.characters.count
        if length > 10 {
            let index = mobileNumber.index(mobileNumber.startIndex, offsetBy: 10)
            mobileNumber = mobileNumber.substring(from: index)
        }
        return mobileNumber
    }
    
    class func formatToPhoneNumber(mobileNumber: String) -> String {
        var mobileNumber = mobileNumber
        
        if mobileNumber.characters.count == 10 {
            let number = NSMutableString(string: mobileNumber)
            number.insert("(", at: 0)
            number.insert(")", at: 4)
            number.insert(" ", at: 5)
            number.insert("-", at: 9)
            mobileNumber = number as String
        }
        return mobileNumber
    }
    
    
    // MARK:- Email Id Validation
    class func isValidEmail(emailId: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: emailId)
    }
    
    
    // MARK:- Current User Methods
    class func getUserPool() -> AWSCognitoIdentityUserPool {
        return AWSCognitoIdentityUserPool(forKey: "UserPool")
    }
    
    class func setUserPool(pool: AWSCognitoIdentityUserPool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.pool = pool
    }
    
    class func getCurrentUser() -> User {
        return user
    }
    
    class func setCurrentUser(currentUser: User) {
        user = currentUser
    }
    
    
    // MARK:- Show Normal Alert message
    class func showAlert(title: String, message: String, viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("you have pressed OK button");
        }
        alertController.addAction(OKAction)
        viewController.present(alertController, animated: true, completion:nil)
    }
    
    // MARK:- Show Normal Alert message for disconnected internet
    class func showAlertForInternetNotReachable(viewController: UIViewController) {
        let alertController = UIAlertController(title: "No Internet Connection", message: "Sorry, no Internet connectivity detected. Please reconnect and try again!", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        viewController.present(alertController, animated: true, completion:nil)
    }
    
    
    
    // MARK:- Button & TextField layer Properties declared Methods
    class func setNextBtnLayerProperty(button: UIButton) {
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        button.layer.borderWidth = 1.0
    }
    
    class func setTextFieldLayerProperty(textField: UITextField) {
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 5.0
        textField.layer.borderColor = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1).cgColor
        textField.layer.borderWidth = 1.0
    }
    
    class func disableNextBtn(button: UIButton) {
        button.isEnabled = false
        button.backgroundColor = #colorLiteral(red: 0.8078431373, green: 0.9137254902, blue: 0.9529411765, alpha: 1)
        button.setTitleColor( #colorLiteral(red: 0.04705882353, green: 0.6941176471, blue: 0.9490196078, alpha: 0.5) , for: .normal)
    }
    
    class func enableNextBtn(button: UIButton) {
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.04705882353, green: 0.6980392157, blue: 0.9529411765, alpha: 1)
        button.setTitleColor( #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) , for: .normal)
    }
    
    class func getNextBtn() -> UIButton {
        let size = UIScreen.main.bounds
        let button = UIButton(frame: CGRect(x: 0, y: size.height - 120, width: size.width, height: 60))
        button.setTitle("Next", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        Utils.disableNextBtn(button: button)
        return button
    }
    
    // MARK:- Show & Hide HUD
    class func showHUD(view: UIView) {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading..."
    }
    
    class func hideHUD(view: UIView) {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    
    // MARK:- Empty SignUp Struct object
    class func emptySignUpVar() {
        signupObj.firstName   = ""
        signupObj.lastName    = ""
        signupObj.emailID     = ""
        signupObj.password    = ""
        signupObj.confirmPWD  = ""
        signupObj.phoneNumber = ""
        signupObj.userRole    = ""
        signupObj.doctorCode  = ""
        signupObj.dateOfBirth = ""
        signupObj.doctorTitle = ""
        signupObj.doctorType  = ""
        signupObj.doctor_charge  = ""
        signupObj.doctor_addr_street = ""
        signupObj.doctor_addr_unit   = ""
        signupObj.doctor_addr_city   = ""
        signupObj.doctor_addr_state  = ""
        signupObj.doctor_addr_zip    = ""
        signupObj.doctor_office_phNo = ""
    }
    
    // MARK:- Get Users country code
    class func getPhoneNoCountryCode() -> String {
        var countryCode = String()
        var phCountryCode = String()
        
        if let countryCodeLocal = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCodeLocal)
            countryCode = countryCodeLocal
        }
        
        if let filePath = Bundle.main.path(forResource: "Phone", ofType: "json"), let data = NSData(contentsOfFile: filePath) {
            do {
                let json = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                
                if let dict = json as? [String: AnyObject] {
                    if let phCountryCodeLocal = dict[countryCode] as? String {
                        phCountryCode = "+\(phCountryCodeLocal)"
                    }
                }
            }
            catch {
                print("Error found for getting phone number country code.")
            }
        }
        
        print("Your Phone number country code is: \(phCountryCode)")
        return phCountryCode
    }
    
    //MARK:- CW Status notification methods
    class func setupNotification() {
        self.notification = CWStatusBarNotification()
        self.notification?.notificationLabelBackgroundColor = #colorLiteral(red: 0.04705882353, green: 0.6980392157, blue: 0.9529411765, alpha: 1)
        self.notification?.notificationLabelFont = UIFont.systemFont(ofSize: 16)
        
        self.notification?.notificationAnimationInStyle = CWNotificationAnimationStyle(rawValue: 0)!
        self.notification?.notificationAnimationOutStyle = CWNotificationAnimationStyle(rawValue: 0)!
        self.notification?.notificationStyle = CWNotificationStyle(rawValue: 1)!
    }
    
    
    // MARK:- Password validation Methods
    class func isPWDContainsRequiredChars(password: String) -> Bool {
        let requiredChars = 8
        if password.characters.count < requiredChars {
            return false
        } else {
            return true
        }
    }
    
    class func isPWDContainsNumbers(password: String) -> Bool {
        let numberRegEx  = ".*[0-9]+.*"
        let perdicate = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let result = perdicate.evaluate(with: password)
        return result
    }
    
    class func isPWDContainsSpecialChars(password: String) -> Bool {
        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        let predicate = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let result = predicate.evaluate(with: password)
        return result
    }
    
    class func isPWDContainsUpperCase(password: String) -> Bool {
        let upperCaseRegEx  = "^.*(?=.{6,})(?=.*[A-Z]).*$"
        let texttest3 = NSPredicate(format:"SELF MATCHES %@", upperCaseRegEx)
        let result = texttest3.evaluate(with: password)
        return result
    }
    
    class func isPWDContainsLowerCase(password: String) -> Bool {
        let lowerCaseRegEx  = "^.*(?=.{6,})(?=.*[a-z]).*$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", lowerCaseRegEx)
        let result = predicate.evaluate(with: password)
        return result
    }
    
    class func isStringContainsNumbersSymbols(text: String) -> Bool {
        let characterset = CharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ'-")
        if text.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }
        
        return true
    }
    
    //MARK:- Get UserDetails & CognitoID Methods
    class func getUserDetails(viewController: UIViewController) {
        Utils.isInSplashVC = false
        appdelegate.user.getDetails().continue({ (task) -> Any? in
            DispatchQueue.main.async {
                
                if task.error != nil {
                    Utils.getUserPool().clearLastKnownUser()
                    appdelegate.user.signOut()
                    appdelegate.setupAWSCongnito()
                    
                    Utils.showHomeScreen()
                } else {
                    if let response: AWSCognitoIdentityUserGetDetailsResponse = task.result {
                        let user = User()
                        user.doctor_addr_state = response.userAttributes?[0].value
                        user.id = response.userAttributes?[1].value
                        user.cardId = response.userAttributes?[2].value
                        user.customerId = response.userAttributes?[3].value
                        user.dateOfBirth = response.userAttributes?[4].value
                        user.isEmailVerified = response.userAttributes?[5].value == "true" ? true : false
                        user.doctor_addr_zip = response.userAttributes?[6].value
                        user.doctor_addr_unit = response.userAttributes?[7].value
                        user.doctorType = response.userAttributes?[8].value
                        user.isPhNoVerified = response.userAttributes?[9].value == "true" ? true : false
                        user.firstName = response.userAttributes?[10].value
                        user.doctorCharge = response.userAttributes?[11].value
                        user.phCountryCode = response.userAttributes?[12].value
                        user.userRole = response.userAttributes?[13].value
                        user.doctor_addr_city = response.userAttributes?[14].value
                        user.lastName = response.userAttributes?[15].value
                        user.profilePicUrl = response.userAttributes?[16].value == "nil" ? nil: response.userAttributes?[16].value
                        user.doctor_addr_street = response.userAttributes?[17].value
                        user.phoneNumber = response.userAttributes?[18].value
                        user.doctor_office_phno = response.userAttributes?[19].value
                        user.doctorTitle = response.userAttributes?[20].value
                        user.emailID = response.userAttributes?[21].value
                        user.name = response.username!
                        user.iSCardWorking = true
                        Utils.setCurrentUser(currentUser: user)
                        Utils.sendPendingMessagesToServer()
                        self.sendDeviceToken()
                        
                        if Utils.user.cardId! != "nil" {
                            Utils.getCardDetails(viewController: viewController, from: "LoginViewController")
                        } else {
                            
                            if Utils.user.doctorCharge == "nil" && Utils.user.userRole! == "Doctor" {
                                
                                let doctorChargeVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorChargeViewController") as! DoctorChargeViewController
                                doctorChargeVC.isUpdateCharge = false
                                
                                doctorChargeVC.modalPresentationStyle = .custom
                                doctorChargeVC.modalTransitionStyle = .crossDissolve
                                
                                let navigationController = UINavigationController(rootViewController: doctorChargeVC)
                                navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.9907117486, green: 0.8272568583, blue: 0.349744916, alpha: 1)
                                navigationController.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                                navigationController.navigationBar.isTranslucent = false
                                viewController.present(navigationController, animated: true, completion: nil)
                            } else {
                                let tabbarVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                                tabbarVC.selectedIndex = 2
                                tabbarVC.modalPresentationStyle = .custom
                                tabbarVC.modalTransitionStyle = .crossDissolve
                                
                                let navigationController = UINavigationController(rootViewController: tabbarVC)
                                navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.9907117486, green: 0.8272568583, blue: 0.349744916, alpha: 1)
                                navigationController.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                                navigationController.navigationBar.isTranslucent = false
                                
                                viewController.present(navigationController, animated: true, completion: nil)
                                
                            }
                        }
                    }
                    
                    appdelegate.user.updateDeviceStatus(false)
                }
            }
            return nil
        })
    }
    
    class func getCardDetails(viewController: UIViewController, from: String) {
        if from != "LoginViewController" {
            Utils.showHUD(view: viewController.view.window!)
        }
        
        DocTextApi.getCardDetails(customerId: Utils.user.customerId!, cardId: Utils.user.cardId!) { (result, error) in
            DispatchQueue.main.async {
                if from != "LoginViewController" {
                    Utils.hideHUD(view: viewController.view.window!)
                }
                
                if error != nil {
                    Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: viewController)
                } else {
                    
                    let status = result!["success"] as? Int
                    if status != nil && status == 1 {
                        let cardDetail = result!["card"] as? Dictionary<String, Any>
                        Utils.user.cardBrand = cardDetail!["brand"] as? String
                        Utils.user.cardLastFourDigit = cardDetail!["last4"] as? String
                        Utils.user.cardExpMonth = cardDetail!["exp_month"] as? Int
                        Utils.user.cardExpYear = cardDetail!["exp_year"] as? Int
                        Utils.user.cardZipCode = cardDetail!["address_zip"] as? String
                        Utils.user.iSCardWorking = true
                        moveToTabbar(viewController: viewController, from: from)
                    } else {
                        Utils.user.iSCardWorking = false
                        print("Card is not working: \(result)")
                        
                        var errorMessage = "Something went wrong!"
                        if let valError = result!["validationError"] as? Dictionary<String, Any> {
                            if let errMsg = valError["message"] as? String {
                                errorMessage = errMsg
                            }
                        }
                        
                        Utils.showAlert(title: "Error Found", message: errorMessage, viewController: viewController)
                        
                        if from == "LoginViewController" {
                            
                            let tabbarVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                            tabbarVC.selectedIndex = 2
                            tabbarVC.modalPresentationStyle = .custom
                            tabbarVC.modalTransitionStyle = .crossDissolve
                            
                            let navigationController = UINavigationController(rootViewController: tabbarVC)
                            navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.9907117486, green: 0.8272568583, blue: 0.349744916, alpha: 1)
                            navigationController.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                            navigationController.navigationBar.isTranslucent = false
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = navigationController
                            viewController.present(navigationController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    class func moveToTabbar(viewController: UIViewController, from: String) {
        if from == "LoginViewController" {
            
            let tabbarVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            tabbarVC.selectedIndex = 2
            tabbarVC.modalPresentationStyle = .custom
            tabbarVC.modalTransitionStyle = .crossDissolve
            
            let navigationController = UINavigationController(rootViewController: tabbarVC)
            navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.9907117486, green: 0.8272568583, blue: 0.349744916, alpha: 1)
            navigationController.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            navigationController.navigationBar.isTranslucent = false
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = navigationController
            viewController.present(navigationController, animated: true, completion: nil)
        } else {
            _ = viewController.navigationController?.popViewController(animated: true)
        }
        
    }
    
    class func updateUserDetails(user: User, viewController: UIViewController) {
        Utils.showHUD(view: viewController.view.window!)
        
        DocTextApi.updateUser(user: user) { (result, error) in
            DispatchQueue.main.async {
                Utils.hideHUD(view: viewController.view.window!)
                if error != nil {
                    Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: viewController)
                } else {
                    if result == "success" {
                        Utils.user.firstName = user.firstName!
                        Utils.user.lastName = user.lastName!
                        Utils.user.profilePicUrl = user.profilePicUrl
                        Utils.user.dateOfBirth = user.dateOfBirth!
                        Utils.user.doctorTitle = user.doctorTitle!
                        Utils.user.doctorType = user.doctorType!
                        Utils.user.doctor_addr_street = user.doctor_addr_street!
                        Utils.user.doctor_addr_unit = user.doctor_addr_unit!
                        Utils.user.doctor_addr_city = user.doctor_addr_city!
                        Utils.user.doctor_addr_state = user.doctor_addr_state!
                        Utils.user.doctor_addr_zip = user.doctor_addr_zip!
                        Utils.user.doctor_office_phno = user.doctor_office_phno!
                        Utils.user.doctorCharge = user.doctorCharge!
                        
                        _ = viewController.navigationController?.popViewController(animated: true)
                    } else {
                        Utils.showAlert(title: "Error Found", message: "Something went wrong!", viewController: viewController)
                    }
                }
            }
        }
    }
    
    class func getCognitoCredentials(viewController: UIViewController) {
        Utils.showHUD(view: viewController.view)
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .usWest2, identityPoolId: COGNITO_IDENTITY_POOL_ID, identityProviderManager: AWSCognitoIdentityUserPool(forKey: "UserPool"))
        let defaultConfiguration = AWSServiceConfiguration(region:.usWest2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultConfiguration
        
        credentialsProvider.getIdentityId().continue({ (task) -> Any? in
            DispatchQueue.main.async {
                Utils.hideHUD(view: viewController.view)
                if task.error != nil {
                    print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                    print(((task.error as! NSError).userInfo["message"] as? String)!)
                    Utils.showAlert(title: "Error", message: ((task.error as! NSError).userInfo["message"] as? String)!, viewController: viewController)
                    
                } else {
                    let cognitoId = credentialsProvider.identityId
                    print("CognitoID: \(cognitoId!)  \(credentialsProvider)")
                    print(credentialsProvider.identityProvider.token())
                    print(AWSCognitoIdentityUserPool(forKey: "UserPool").currentUser()?.username!);
                    Utils.getUserDetails(viewController: viewController)
                }
            }
            return nil
        })
    }
    
    class func sendDeviceToken() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            if let token = Utils.deviceToken {
                DocTextApi.saveDeviceToken(deviceToken: token, completionHandler: { (result, error) in
                    DispatchQueue.main.async {
                        if (error != nil) {
                            print("SaveDeviceToken: Error found")
                        } else {
                            let status = result?["success"] as? Int
                            if status != nil && status! == 1 {
                                print("SaveDeviceToken: success")
                            }
                        }
                    }
                })
            }
        } else {
            print("internet not connected...")
        }
    }
    
    class func removeDeviceToken() {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            DocTextApi.removeDeviceToken(completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    if (error != nil) {
                        print("RemoveDeviceToken: Error found")
                    } else {
                        let status = result?["success"] as? Int
                        if status != nil && status! == 1 {
                            print("RemoveDeviceToken: success")
                        }
                    }
                }
            })
        } else {
            print("internet not connected...")
        }
    }
    
    class func signOut() {
        let messageDA = MessageDA()
        FileUtils.removeAllFiles()
        messageDA.deleteMessages()
        Utils.removeDeviceToken()
        Utils.getUserPool().clearLastKnownUser()
        appdelegate.user.signOut()
        Utils.clearSDImageCache()
        Utils.isUnsentMessageProcessing = false
        self.showHomeScreen()
    }
    
    class func clearSDImageCache() {
        let imageCache = SDImageCache.shared()
        imageCache?.clearMemory()
        imageCache?.cleanDisk()
    }

    class func removeAllObserver(controller: UIViewController) {
        for vc  in (controller.navigationController?.viewControllers)! {
            if vc is TabBarViewController {
                let tabbarVC = vc as! TabBarViewController
                
                let dashboardVC = tabbarVC.viewControllers?[1] as! DashboardViewController
                NotificationCenter.default.removeObserver(dashboardVC)
                
                if Utils.getCurrentUser().userRole == "Doctor" {
                    let patientVC = tabbarVC.viewControllers?[0] as! PatientListViewController
                    NotificationCenter.default.removeObserver(patientVC)
                } else {
                    let doctorVC = tabbarVC.viewControllers?[0] as! DoctorsListViewController
                    NotificationCenter.default.removeObserver(doctorVC)
                }
            }
        }
    }
    
    //milliseconds to Date
    class func dateFromMilliseconds(ms: String) -> NSDate {
        return NSDate(timeIntervalSince1970:Double(ms)! / 1000.0)
    }
    
    //Date to milliseconds
    class func millisecondFromDate(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let dateObj = dateFormatter.date(from: dateString)
        
        
        let since1970 = dateObj!.timeIntervalSince1970
        return String(since1970 * 1000)
    }
    
    
    class func convertStringToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        dateFormatter.dateFormat = "yyyy-MM-ddThh:mm:ss.zzzz"
        
        let dateObj = dateFormatter.date(from: dateString)
        
        return dateObj!
    }
    
    class func convertStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        return dateFormatter.string(from: date)
    }
    
    class func convertStringFromDateForDatePicker(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.timeZone = NSTimeZone.system
        return dateFormatter.string(from: date)
    }
    
    class func convertDateFromStringForDatePicker(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateObj = dateFormatter.date(from: dateString)
        return dateObj!
    }
    
    class func convertStringFromDateForExpDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        dateFormatter.timeZone = NSTimeZone.system
        return dateFormatter.string(from: date)
    }
    
    class func convertDateStringForLastMessage(msString: String) -> String {
        let dateObj = Utils.dateFromMilliseconds(ms: msString)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        let calendar = NSCalendar.autoupdatingCurrent
        if calendar.isDateInToday(dateObj as Date) {
            dateFormatter.dateFormat = "hh:mm a"
            dateFormatter.timeZone = NSTimeZone.system
            return dateFormatter.string(from: dateObj as Date).lowercased()
        } else if calendar.isDateInYesterday(dateObj as Date) {
            return "yesterday"
        } else {
            dateFormatter.dateFormat = "MMM dd"
            dateFormatter.timeZone = NSTimeZone.system
            return dateFormatter.string(from: dateObj as Date)
        }
    }
    
    class func convertDateStringForDateString(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateFormatter.timeZone = NSTimeZone.system
        return dateFormatter.string(from: dateObj!).lowercased()
    }
    
    class func convertDateStringForDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let dateObj = dateFormatter.date(from: dateString)
        
        return dateObj!
    }
    
    class func pickColor(alphabet: Character) -> UIColor {
        let alphabetColors = [0x5A8770, 0xB2B7BB, 0x6FA9AB, 0xF5AF29, 0x0088B9, 0xF18636, 0xD93A37, 0xA6B12E, 0x5C9BBC, 0xF5888D, 0x9A89B5, 0x407887, 0x9A89B5, 0x5A8770, 0xD33F33, 0xA2B01F, 0xF0B126, 0x0087BF, 0xF18636, 0x0087BF, 0xB2B7BB, 0x72ACAE, 0x9C8AB4, 0x5A8770, 0xEEB424, 0x407887]
        let str = String(alphabet).unicodeScalars
        let unicode = Int(str[str.startIndex].value)
        if 65...90 ~= unicode {
            let hex = alphabetColors[unicode - 65]
            return UIColor(red: CGFloat(Double((hex >> 16) & 0xFF)) / 255.0, green: CGFloat(Double((hex >> 8) & 0xFF)) / 255.0, blue: CGFloat(Double((hex >> 0) & 0xFF)) / 255.0, alpha: 1.0)
        }
        return UIColor.black
    }
    
    class func getFirstCharOfNames(userName: String) -> (String, String, String, String) {
        let name = userName
        let nameArray = name.components(separatedBy: "__")
        var FNFC = name[name.startIndex]
        var LNFC = name[name.startIndex]
        var firtString = String()
        var lastString = String()
        if nameArray.count >= 2 {
            firtString = nameArray[0]
            lastString = nameArray[1]
            FNFC = firtString[firtString.startIndex]
            LNFC = lastString[lastString.startIndex]
        }
        
        return (String(FNFC).uppercased(), String(LNFC).uppercased(), firtString, lastString)
    }
    
    class func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    class func rotateImage(image: UIImage) -> UIImage {
        if (image.imageOrientation == UIImageOrientation.up ) {
            return image
        }
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return copy!
    }
    
    // Store and Read file from local bundle...
    class func storeFileToLocal(fileData: Data, fileName: String, fileEx: String) -> String? {
        do {
            let documentsURL = FileUtils.getMediaPath()
            let fileURL = documentsURL?.stringByAppendingPathComponent(path: "\(fileName)\(fileEx)")
            try fileData.write(to: URL(string: "file://\(fileURL!)")!, options: .atomic)
            return fileURL
        } catch {
            print("Exception occured whil storing file to local...")
        }
        
        return nil
    }
    
    class func readFileFromLocal(fileName: String, fileEx: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(fileName)\(fileEx)").path
        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        
        return ""
    }
    
    class func drawImage(image foreGroundImage:UIImage, inImage backgroundImage:UIImage) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.draw(in: CGRect(x: 0, y: 0, width: backgroundImage.size.width, height: backgroundImage.size.height))
        foreGroundImage.draw(in: CGRect(x: backgroundImage.size.width / 2, y: backgroundImage.size.height / 2, width: backgroundImage.size.width / 2, height: backgroundImage.size.height / 2))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    class func sendPendingMessagesToServer() {
        let unsentMessages = Utils.messageDA.fetchUnSentMessageList()
        if unsentMessages.count != 0 && !Utils.isUnsentMessageProcessing {
            Utils.isUnsentMessageProcessing = true
            let messageObj = unsentMessages[0]
            if messageObj.payment_status == "Paid" {
                if messageObj.message_type == MEDIA_TYPE_TEXT {
                    messageObj.media_url = "nil"
                    messageObj.message_status = Utils.IsCurrentUserIsPatient() ? MESSAGE_STATUS_NOT_DELIVERED : MESSAGE_STATUS_SENT
                    Utils.publishToTopic(msg: messageObj)
                } else {
                    Utils.uploadFileToS3(unsentMsg: messageObj)
                }
            }
        } else {
        }
    }
    
    class func publishToTopic(msg: Message) {
        
        DispatchQueue.global(qos: .background).async {
            
            let sns = AWSSNS.default()
            let request = AWSSNSPublishInput()
            request?.messageStructure = "json"
            request?.targetArn = "arn:aws:sns:us-east-1:717363038630:MrText"
            let dict = ["default": "{\"message\":\"\(msg.message!)\",\"message_status\":\"\(Utils.IsCurrentUserIsPatient() ? MESSAGE_STATUS_NOT_DELIVERED : MESSAGE_STATUS_SENT)\",\"media_url\":\"\(msg.media_url!)\",\"roomID\":\"\(msg.room_id!)\",\"chargeId\":\"\(msg.transactionId!)\",\"lastName\":\"\(Utils.getCurrentUser().lastName!)\",\"firstName\":\"\(Utils.getCurrentUser().firstName!)\",\"receiverId\":\"\(msg.receiver_Id!)\",\"sent_time\":\"\(msg.sent_time!)\",\"messageType\":\"\(msg.message_type!)\",\"senderID\":\"\(msg.sender_Id!)\"}"]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                request?.message = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String?
                sns.publish(request!, completionHandler: { (response, error) in
                    DispatchQueue.main.async {
                        if (error != nil) {
                            print("Error found: \(error)")
                            Utils.isUnsentMessageProcessing = false
                        } else {
                            print("Published successfully to topic...")
                            print("Message ID: \(response?.messageId)")
                            
                            let messageObj = self.messageDA.fetchMessageWith(sentTime: msg.sent_time!)
                            messageObj?.message_id = response?.messageId
                            messageObj?.message_status = Utils.IsCurrentUserIsPatient() ? MESSAGE_STATUS_NOT_DELIVERED : MESSAGE_STATUS_SENT
                            self.messageDA.addUpdateMessages(message: messageObj!)
                            let sendMessageDict:[String: Message] = ["sentMessage": messageObj!]
                            NotificationCenter.default.post(name: Utils.chatRefreshNotification, object: nil, userInfo: sendMessageDict)
                            Utils.isUnsentMessageProcessing = false
                            Utils.sendPendingMessagesToServer()
                        }
                    }
                })
            } catch {
                print("Exception found...")
            }
        }
    }
    
    class func uploadFileToS3(unsentMsg: Message) {
        
        var key = ""
        var contentType = ""
        if unsentMsg.message_type! == MEDIA_TYPE_IMAGE {
            key = ProcessInfo.processInfo.globallyUniqueString + "." + "png"
            contentType = "image/png"
        } else if unsentMsg.message_type! == MEDIA_TYPE_VIDEO {
            key = ProcessInfo.processInfo.globallyUniqueString + "." + "mov"
            contentType = "movie/mov"
        } else if unsentMsg.message_type! == MEDIA_TYPE_AUDIO {
            key = ProcessInfo.processInfo.globallyUniqueString + "." + "m4a"
            contentType = "audio/m4a"
        }
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = NSURL(string: unsentMsg.videoLocalUrl!) as URL!
        uploadRequest?.key = key
        uploadRequest?.bucket = AWS_S3_BUCKETNAME + AWS_S3_MEDIA_FILE_FOLDER
        uploadRequest?.contentType = contentType
        let keyValue = uploadRequest?.key
        
        let transferManager = AWSS3TransferManager.default()
        transferManager?.upload(uploadRequest).continue({ (task) -> Any? in
            
            if let error = task.error {
                print("Upload failed ❌ (\(error))")
            }
            if let exception = task.exception {
                print("Upload failed ❌ (\(exception))")
            }
            if task.result != nil {
                let s3URL = "http://s3.amazonaws.com/\(AWS_S3_BUCKETNAME + AWS_S3_MEDIA_FILE_FOLDER)/\(keyValue!)"
                print("Uploaded to:\n\(s3URL)🐬")
                unsentMsg.media_url = s3URL
                self.messageDA.addUpdateMessages(message: unsentMsg)
                Utils.publishToTopic(msg: unsentMsg)
            }
            else {
                print("Unexpected empty result.")
            }
            
            return nil
        })
    }
    
    
    // Notify Internet connected or disconnected...
    class func notifyWhenInternetDisconnected() {
        
        print(reachability.currentReachabilityStatus)
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                print(reachability.currentReachabilityStatus)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                if appDelegate.window?.rootViewController is SplashViewController && self.isInSplashVC {
                    Utils.getUserDetails(viewController: appDelegate.window?.rootViewController as! SplashViewController)
                }
            }
        }
        
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                print("Internet Not Reachable")
                print(reachability.currentReachabilityStatus)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    // Enable and Disable check box...
    class func enableCheckBox(checkBoxBtn: UIButton) {
        checkBoxBtn.layer.masksToBounds = true
        checkBoxBtn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        checkBoxBtn.layer.borderWidth = 0.0
        checkBoxBtn.backgroundColor = #colorLiteral(red: 0.4980392157, green: 0.9882352941, blue: 0.662745098, alpha: 1)
        checkBoxBtn.tag = 1
    }
    
    class func disableCheckBox(checkBoxBtn: UIButton) {
        checkBoxBtn.layer.masksToBounds = true
        checkBoxBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        checkBoxBtn.layer.borderWidth = 1.0
        checkBoxBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        checkBoxBtn.tag = 0
    }
    
    class func getProgressPercentage(totoalVal: Double, currentVal: Double) -> Float {
        return Float((1.0 / totoalVal) * currentVal)
    }
    
    
    class func getAgeFromDate(birthday: String) -> Int {
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        dateFormater.timeZone = NSTimeZone.system
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let now: NSDate! = NSDate()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now as Date, options: [])
        let age = calcAge.year
        return age!
    }
    
    class func showHomeScreen() {
        let introScreenVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "IntroductionViewController")
        
        introScreenVC.modalPresentationStyle = .custom
        introScreenVC.modalTransitionStyle = .crossDissolve
        
        let navigationController = UINavigationController(rootViewController: introScreenVC)
        navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.9907117486, green: 0.8272568583, blue: 0.349744916, alpha: 1)
        navigationController.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController.navigationBar.isTranslucent = false
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    
    class func getDeviceId() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    class func setAllReadyInstalled(value: Bool) {
        UserDefaults.standard.set(value, forKey: "AllReadyInstalled")
    }
    
    class func getAllReadyInstalled() -> Bool {
        return UserDefaults.standard.bool(forKey: "AllReadyInstalled")
    }
    
    class func getAbbrivatedBrandName(brandName: String) -> String {
        if brandName == "Visa" {
            return "Visa"
        } else if brandName == "MasterCard" {
            return "MasterCard"
        } else if brandName == "American Express" {
            return "amex"
        } else if brandName == "Maestro" {
            return "Maestro"
        } else if brandName == "JCB" {
            return "JCB"
        } else if brandName == "Discover" {
            return "Discover"
        } else if brandName == "Diners Club" {
            return "Diners Club"
        }
        else{
            return ""
        }
    }
    
    class func thumbnailForVideoAtURL(url: URL) -> UIImage? {
        
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let image: UIImage
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil)
            image = UIImage(cgImage: cgImage)
            return image
        } catch let error as NSError {
            print("Error occured thumbnailForVideoAtURL: \(error.localizedDescription) and url is \(url)")
        }
        return nil
    }
    
    class func IsCurrentUserIsPatient() -> Bool {
        if Utils.getCurrentUser().userRole! == "Doctor" {
            return false
        } else {
            return true
        }
    }
    
    class func cropToBounds(image: UIImage) -> UIImage {
        var width = image.size.width
        var height = image.size.height
        
        if width > height {
            height = width
        } else {
            width = height
        }
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x:posX, y:posY, width:cgwidth, height:cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    class func openAppInSettings() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
}
