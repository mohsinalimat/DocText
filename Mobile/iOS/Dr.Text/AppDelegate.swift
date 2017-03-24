//
//  AppDelegate.swift
//  Dr.Text
//
//  Created by SoftSuave on 07/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import CoreData
import AWSCore
import AWSCognitoIdentityProvider
import UserNotifications
import AWSSNS
import JSQMessagesViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AWSCognitoIdentityInteractiveAuthenticationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser!
    var introductionViewController: IntroductionViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Utils.isUnsentMessageProcessing = false
        UIApplication.shared.statusBarStyle = .lightContent
        self.setupAWSCongnito()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                UIApplication.shared.registerForRemoteNotifications()
            })
        } else {
            let readAction = UIMutableUserNotificationAction()
            readAction.identifier = "READ_IDENTIFIER";
            readAction.title = "Read";
            readAction.activationMode = UIUserNotificationActivationMode.foreground;
            readAction.isDestructive = false;
            readAction.isAuthenticationRequired = true;
            
            let deleteAction = UIMutableUserNotificationAction()
            deleteAction.identifier = "DELETE_IDENTIFIER";
            deleteAction.title = "Delete";
            deleteAction.activationMode = UIUserNotificationActivationMode.foreground;
            deleteAction.isDestructive = true;
            deleteAction.isAuthenticationRequired = true;
            
            let ignoreAction = UIMutableUserNotificationAction()
            ignoreAction.identifier = "IGNORE_IDENTIFIER";
            ignoreAction.title = "Ignore";
            ignoreAction.activationMode = UIUserNotificationActivationMode.foreground;
            ignoreAction.isDestructive = false;
            ignoreAction.isAuthenticationRequired = false;
            
            let messageCategory = UIMutableUserNotificationCategory()
            messageCategory.identifier = "MESSAGE_CATEGORY"
            messageCategory.setActions([readAction, deleteAction], for: UIUserNotificationActionContext.minimal)
            messageCategory.setActions([readAction, deleteAction, ignoreAction], for: UIUserNotificationActionContext.default)
            
            let notificationSettings = UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: NSSet(array: [messageCategory]) as? Set<UIUserNotificationCategory>)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        Utils.notifyWhenInternetDisconnected()
        UIApplication.shared.cancelAllLocalNotifications()
        application.applicationIconBadgeNumber = 0
        return true
    }
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        var loginViewController: LoginViewController? = nil
        loginViewController = Utils.getStoryBoard().instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        loginViewController?.delegate = self.introductionViewController
        self.introductionViewController?.navigationController?.pushViewController(loginViewController!, animated: true)
        return loginViewController!
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("DeviceToken: \(deviceTokenString)")
        Utils.deviceToken = deviceTokenString
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("i am not available in simulator \(error)")
    }
    
    @available(iOS 10.0, *)
    private func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        print("willPresentNotification")
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Calling background fetch option....")
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        UIApplication.shared.cancelAllLocalNotifications()
        if application.applicationState == .active {
            let messageDA = MessageDA()
            if let aps = userInfo["aps"] as? NSDictionary {
                if let roomId = aps["roomId"] as? String {
                    print(roomId)
                }
                let message_id = aps["message_id"] as? String
                let message_type = aps["messageType"] as? String
                let text = aps["message"] as? String
                let room_id = aps["roomId"] as? String
                let sender_id = aps["senderID"] as? String
                let receiver_id = aps["receiverId"] as? String
                let message_status = aps["message_status"] as? String
                let transactionId = "nil"
                let mediaUrl = aps["mediaUrl"] as? String
                let sent_time = aps["sentTime"] as? String
                
                var message: Message? = nil
                if message_type == MEDIA_TYPE_TEXT {
                    message = Message(messageId: message_id,
                                      message: text,
                                      messageType: message_type,
                                      senderId: sender_id,
                                      roomId: room_id,
                                      sendTimeString: sent_time,
                                      sendTimeobject: nil,
                                      receiverId: receiver_id!,
                                      message_status: message_status!,
                                      paymentStatus: "Paid",
                                      transactionId: transactionId)
                } else if message_type == MEDIA_TYPE_IMAGE {
                    message = Message(messageId: message_id,
                                      message: text,
                                      messageType: message_type,
                                      senderId: sender_id,
                                      roomId:  room_id,
                                      sendTimeString: sent_time,
                                      sendTimeobject: nil,
                                      media: JSQPhotoMediaItem(image: #imageLiteral(resourceName: "placeholder")),
                                      media_Msg_Data: UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder")),
                                      mediaUrl: mediaUrl,
                                      receiverId: receiver_id!,
                                      message_status: message_status!,
                                      thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                      videoLocalUrl: nil,
                                      paymentStatus: "Paid",
                                      transactionId: transactionId)
                    
                } else if message_type == MEDIA_TYPE_VIDEO {
                    message = Message(messageId: message_id,
                                      message: text,
                                      messageType: message_type,
                                      senderId: sender_id,
                                      roomId:  room_id,
                                      sendTimeString: sent_time,
                                      sendTimeobject: nil,
                                      media: JSQPhotoMediaItem(image: #imageLiteral(resourceName: "placeholder")),
                                      media_Msg_Data: UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder")),
                                      mediaUrl: mediaUrl,
                                      receiverId: receiver_id!,
                                      message_status: message_status!,
                                      thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                      videoLocalUrl: nil,
                                      paymentStatus: "Paid",
                                      transactionId: transactionId)
                    
                } else if message_type == MEDIA_TYPE_AUDIO {
                    message = Message(messageId: message_id,
                                      message: text,
                                      messageType: message_type,
                                      senderId: sender_id,
                                      roomId:  room_id,
                                      sendTimeString: sent_time,
                                      sendTimeobject: nil,
                                      media: nil,
                                      media_Msg_Data: nil,
                                      mediaUrl: mediaUrl,
                                      receiverId: receiver_id!,
                                      message_status: message_status!,
                                      thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                      videoLocalUrl: nil,
                                      paymentStatus: "Paid",
                                      transactionId: transactionId)
                    
                }
                
                messageDA.addUpdateMessages(message: message!)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChatNotification"), object: nil)
                
                let myDict = ["lastMessage": message]
                NotificationCenter.default.post(name: Notification.Name("UnreadMsgNotification"), object: myDict)
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Dr_Text", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Dr_Text.sqlite")
        print("database url: \(url)")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func setSlideMenu() {
        let leftMenuVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "LeftViewController")
        SlideNavigationController.sharedInstance().leftMenu = leftMenuVC
    }
    
    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootVC?.presentedViewController == nil {
            return rootVC
        }
        
        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }
            
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }
    
    
    //MARK: - Setup AWS Cognito
    func setupAWSCongnito() {
        let serviceConfiguration = AWSServiceConfiguration(region: .usWest2, credentialsProvider: nil)
        let configuration = AWSCognitoIdentityUserPoolConfiguration(clientId: COGNITO_USER_POOL_APP_CLIENT_ID, clientSecret: COGNITO_USER_POOL_APP_CLIENT_SECRET, poolId: COGNITO_USER_POOL_ID)
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: configuration, forKey: "UserPool")
        pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        self.pool!.delegate = self
        self.user = self.pool!.currentUser()
    }
    
    func setCredentialProviders() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .usWest2, identityPoolId: COGNITO_IDENTITY_POOL_ID, identityProviderManager: pool)
        let defaultServiceConfiguration = AWSServiceConfiguration(region: .usWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
    }
}

