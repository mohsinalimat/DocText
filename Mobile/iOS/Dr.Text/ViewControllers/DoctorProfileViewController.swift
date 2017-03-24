//
//  DoctorProfileViewController.swift
//  Dr.Text
//
//  Created by SoftSuave on 08/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import MobileCoreServices
import AWSS3
import AWSCore
import AWSCognitoIdentityProvider
import SDWebImage
import MBProgressHUD

class DoctorProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var containerViewWCons: NSLayoutConstraint!
    @IBOutlet weak var mainNameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailValLbl: UILabel!
    @IBOutlet weak var passwordValLbl: UILabel!
    @IBOutlet weak var typeOfDocValLbl: UILabel!
    @IBOutlet weak var titleValLbl: UILabel!
    @IBOutlet weak var addrValLbl: UILabel!
    @IBOutlet weak var imageOutterView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var typeOfDoctorView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var chargeView: UIView!
    @IBOutlet weak var chargeLbl: UILabel!
    @IBOutlet weak var profilePicImageView: UIImageView!
    var imagePicker = UIImagePickerController()
    var uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var loadingNotification: MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageOutterView.layer.masksToBounds = true
        imageOutterView.layer.cornerRadius = imageOutterView.frame.size.height / 2
        
        profilePicImageView.layer.masksToBounds = true
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let rightBarBtn = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(DoctorProfileViewController.logout(rightBarBtn:)))
        self.tabBarController?.navigationItem.rightBarButtonItem = rightBarBtn
        
        updateLayerProperties()
        updateUserDetails()
        downloadProfilePic()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerViewHCons.constant = self.chargeView.frame.origin.y + self.chargeView.frame.size.height + 10
        containerViewWCons.constant = (self.scrollView?.frame.width)!
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
    }
    
    //MARK:- IBActions
    @IBAction func actionOnChoosePic(_ sender: UIButton) {
        showActionSheet()
    }
    
    @IBAction func actionOnNameView(_ sender: UIButton) {
        let changeNameVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ChangeNameViewController") as! ChangeNameViewController
        navigationController?.pushViewController(changeNameVC, animated: true)
    }
    
    @IBAction func actionOnEmailView(_ sender: UIButton) {
        
    }
    
    @IBAction func actionOnPasswordView(_ sender: UIButton) {
        let changePWDVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ChangePWDViewController") as! ChangePWDViewController
        navigationController?.pushViewController(changePWDVC, animated: true)
    }
    
    @IBAction func actionOnTypeOfDocView(_ sender: UIButton) {
        let changeDocTypeVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ChangeDocTypeViewController") as! ChangeDocTypeViewController
        navigationController?.pushViewController(changeDocTypeVC, animated: true)
    }
    
    @IBAction func actionOnTitleView(_ sender: UIButton) {
        let changeDocTitleVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ChangeDocTitleViewController") as! ChangeDocTitleViewController
        navigationController?.pushViewController(changeDocTitleVC, animated: true)
    }
    
    @IBAction func actionOnChargeView(_ sender: UIButton) {
        let doctorChargeVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "DoctorChargeViewController") as! DoctorChargeViewController
        doctorChargeVC.isUpdateCharge = true
        navigationController?.pushViewController(doctorChargeVC, animated: true)
    }
    
    @IBAction func actionOnAddrView(_ sender: UIButton) {
        let changeDocAddrVC = Utils.getStoryBoard().instantiateViewController(withIdentifier: "ChangeDocAddrViewController") as! ChangeDocAddrViewController
        navigationController?.pushViewController(changeDocAddrVC, animated: true)
    }
    
    func logout(rightBarBtn: UIBarButtonItem) {
        if Utils.reachability.currentReachabilityStatus != .notReachable {
            Utils.removeAllObserver(controller: self)
            Utils.signOut()
        } else {
            Utils.showAlertForInternetNotReachable(viewController: self)
        }
    }
    
    //MARK:- IBActions
    func updateLayerProperties() {
        nameView.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        nameView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        nameView.layer.shadowOpacity = 1.0
        nameView.layer.shadowRadius = 2.0
        nameView.layer.masksToBounds = false
        
        emailView.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        emailView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        emailView.layer.shadowOpacity = 1.0
        emailView.layer.shadowRadius = 2.0
        emailView.layer.masksToBounds = false
        
        passwordView.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        passwordView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        passwordView.layer.shadowOpacity = 1.0
        passwordView.layer.shadowRadius = 2.0
        passwordView.layer.masksToBounds = false
        
        typeOfDoctorView.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        typeOfDoctorView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        typeOfDoctorView.layer.shadowOpacity = 1.0
        typeOfDoctorView.layer.shadowRadius = 2.0
        typeOfDoctorView.layer.masksToBounds = false
        
        titleView.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        titleView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        titleView.layer.shadowOpacity = 1.0
        titleView.layer.shadowRadius = 2.0
        titleView.layer.masksToBounds = false
        
        addressView.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        addressView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        addressView.layer.shadowOpacity = 1.0
        addressView.layer.shadowRadius = 2.0
        addressView.layer.masksToBounds = false
        
        chargeView.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        chargeView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        chargeView.layer.shadowOpacity = 1.0
        chargeView.layer.shadowRadius = 2.0
        chargeView.layer.masksToBounds = false
    }
    
    func updateUserDetails() {
        mainNameLbl.text = "Hi Dr. \(Utils.user.firstName!) \(Utils.user.lastName!)"
        nameLbl.text = "\(Utils.user.firstName!) \(Utils.user.lastName!)"
        emailValLbl.text = Utils.user.emailID!
        passwordValLbl.text = "********"
        typeOfDocValLbl.text = Utils.user.doctorType!
        titleValLbl.text = Utils.user.doctorTitle!
        let unit = Utils.user.doctor_addr_unit! == "nil" ? "" : ", \(Utils.user.doctor_addr_unit!)"
        addrValLbl.text = "\(Utils.user.doctor_addr_street!)\(unit), \(Utils.user.doctor_addr_city!), \(Utils.user.doctor_addr_state!), \(Utils.user.doctor_addr_zip!)"
        chargeLbl.text = Utils.user.doctorCharge
    }
    
    func showActionSheet() {
        let sheet = UIAlertController(title: "Select Media type", message: nil, preferredStyle: .actionSheet)
        let captureImageAction = UIAlertAction(title: "Capture Image", style: .default) { (action) in
            self.showImagePickerForCaptureImageVideo(type: kUTTypeImage as String)
        }
        
        let existingImageAction = UIAlertAction(title: "Choose Existing Image", style: .default) { (action) in
            self.showImagePickerForChooseExisting()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(captureImageAction)
        sheet.addAction(existingImageAction)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func showImagePickerForChooseExisting() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func showImagePickerForCaptureImageVideo(type: String) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            self.imagePicker.mediaTypes = [type]
            
            self.present(self.imagePicker, animated: true, completion: nil)
        } else {
            Utils.showAlert(title: "", message: "You don't have camera", viewController: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let image = originalImage.resizeWith(percentage: 0.5)
            profilePicImageView.image = Utils.rotateImage(image: image!)
            Utils.user.image = Utils.rotateImage(image: image!)
            Utils.user.profilePicUrl = nil
            if let data = UIImagePNGRepresentation(Utils.rotateImage(image: image!)) {
                let fileurl = getDocumentsDirectory().appendingPathComponent("\(ProcessInfo.processInfo.globallyUniqueString).png")
                try? data.write(to: fileurl)
                uploadImage(fileUrl: fileurl)
            }
            
        } else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // Download Image with Progress
    func downloadProfilePic() {
        if let picUrl = Utils.user.profilePicUrl {
            if !FileUtils.IsImageFileExists(fileName: picUrl) {
                
                SDWebImageManager.shared().downloadImage(with: NSURL(string: picUrl) as URL!, options: [.continueInBackground, .lowPriority], progress: { (min, max) in
                    print("downloading progress \(min) and \(max)")
                }, completed: { (image, error, type, finished, url) in
                    if image != nil {
                        self.profilePicImageView.image = image
                        Utils.user.image = image
                        FileUtils.saveImageAtFileName(image: image!, fileName: (url?.absoluteString)!)
                    } else {
                        print("Image Download error found: \(error)")
                    }
                })
            } else {
                self.profilePicImageView.image = FileUtils.getImage(fileName: picUrl)
                Utils.user.image = FileUtils.getImage(fileName: picUrl)
            }
            
        } else {
            if let userImage = Utils.user.image {
                profilePicImageView.image = userImage
            } else {
                profilePicImageView.image = #imageLiteral(resourceName: "profilePlaceholder")
            }
        }
    }
    
    // Upload Image with Progress
    func uploadImage(fileUrl: URL) {
        
        let keyValue = ProcessInfo.processInfo.globallyUniqueString + "." + "png"
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask, progress: Progress) in
            print("Fraction progress: \(progress.fractionCompleted)")
            DispatchQueue.main.async {
                MBProgressHUD(for: self.view)?.progress = Float(progress.fractionCompleted)
            }
        }
        
        self.uploadCompletionHandler = { (task, error) -> Void in
            DispatchQueue.main.async {
                if ((error) != nil){
                    Utils.hideHUD(view: self.view)
                    print("Failed with error")
                    print("Error: \(error!)");
                    print("Error: \(error.debugDescription)");
                    print("Error: \(error?.localizedDescription)");
                    Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                }
                else {
                    self.loadingNotification.mode = MBProgressHUDMode.indeterminate
                    let s3URL = "http://s3.amazonaws.com/\(AWS_S3_BUCKETNAME + AWS_S3_PROFILE_PIC_FOLDER)/\(keyValue)"
                    print("Profile Picture Uploaded to:\n\(s3URL)")
                    
                    let profilePicAttribute = AWSCognitoIdentityUserAttributeType()
                    profilePicAttribute?.name  = "custom:profilePictureUrl"
                    profilePicAttribute?.value = s3URL
                    
                    Utils.getUserPool().currentUser()?.update([profilePicAttribute!]).continue({ (task) -> Any? in
                        DispatchQueue.main.async {
                            if task.error != nil {
                                Utils.hideHUD(view: self.view)
                                print("Domain: " + ((task.error as! NSError).domain) + " Code: \((task.error as! NSError).code)")
                                print(((task.error as! NSError).userInfo["message"] as? String)!)
                                Utils.showAlert(title: "Error Found", message: (task.error!.localizedDescription) , viewController: self)
                            } else {
                                print("success")
                                Utils.user.profilePicUrl = s3URL
                                self.updateUserTableDetails()
                            }
                        }
                        return nil
                    })
                }
            }
        }
        
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadFile(fileUrl, bucket: AWS_S3_BUCKETNAME + AWS_S3_PROFILE_PIC_FOLDER, key: keyValue, contentType: "image/png", expression: expression, completionHander: uploadCompletionHandler).continue({ (task) -> AnyObject! in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                }
                if let exception = task.exception {
                    print("Exception: \(exception.description)")
                }
                if let _ = task.result {
                    print("Upload Starting!")
                    self.showHUD()
                }
            }
            return nil;
        })
    }
    
    func showHUD() {
        loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.determinate
        loadingNotification.label.text = "Uploading..."
    }
    
    func updateUserTableDetails() {
        let user = Utils.user!
        user.profilePicUrl = Utils.user.profilePicUrl!
        
        DocTextApi.updateUser(user: user) { (result, error) in
            DispatchQueue.main.async {
                Utils.hideHUD(view: self.view)
                if error != nil {
                    Utils.showAlert(title: "Error Found", message: error!.localizedDescription, viewController: self)
                } else {
                    if result == "success" {
                        Utils.user.firstName = user.firstName!
                        Utils.user.lastName = user.lastName!
                        Utils.user.profilePicUrl = user.profilePicUrl!
                        Utils.user.dateOfBirth = user.dateOfBirth!
                        Utils.user.doctorTitle = user.doctorTitle!
                        Utils.user.doctorType = user.doctorType!
                        Utils.user.doctor_addr_street = user.doctor_addr_street!
                        Utils.user.doctor_addr_unit = user.doctor_addr_unit!
                        Utils.user.doctor_addr_city = user.doctor_addr_city!
                        Utils.user.doctor_addr_state = user.doctor_addr_state!
                        Utils.user.doctor_addr_zip = user.doctor_addr_zip!
                    } else {
                        Utils.showAlert(title: "Error Found", message: "Something went wrong!", viewController: self)
                    }
                }
            }
        }
    }
    
}
