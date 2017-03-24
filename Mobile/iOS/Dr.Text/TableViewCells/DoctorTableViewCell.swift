//
//  DoctorTableViewCell.swift
//  Dr.Text
//
//  Created by SoftSuave on 01/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import SDWebImage

protocol doctorTableViewCellDelegate {
    func actionOnSendText(btn: UIButton, indexPath: Int, userImg: UIImage)
}

class DoctorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addrLblHCons: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var doctorTypeLbl: UILabel!
    @IBOutlet weak var contentLblHCons: NSLayoutConstraint!
    @IBOutlet weak var picOutterView: UIView!
    @IBOutlet weak var picImageView: UIImageView!
    @IBOutlet weak var sendTextBtn: UIButton!
    @IBOutlet weak var doctorNameLbl: UILabel!
    @IBOutlet weak var doctorAddrLbl: UILabel!
    var row: Int!
    var delegate: doctorTableViewCellDelegate!
    var roomID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        picOutterView.layer.masksToBounds = true
        picOutterView.layer.cornerRadius = picOutterView.frame.size.height / 2
        
        picImageView.layer.masksToBounds = true
        picImageView.layer.cornerRadius = picImageView.frame.size.width / 2
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 2
    }
    
    // Download Image with Progress
    func downloadProfilePic(url: String?) {
        if let picUrl = url {
            if !FileUtils.IsImageFileExists(fileName: picUrl) {
                SDWebImageManager.shared().downloadImage(with: NSURL(string: picUrl) as URL!, options: [.continueInBackground, .lowPriority], progress: { (min, max) in
                    print("downloading progress \(min) and \(max)")
                }, completed: { (image, error, type, finished, url) in
                    if image != nil {
                        self.picImageView.image = image
                        FileUtils.saveImageAtFileName(image: image!, fileName: (url?.absoluteString)!)
                    } else {
                        print("Image Download error found: \(error)")
                    }
                })
            } else {
                self.picImageView.image = FileUtils.getImage(fileName: picUrl)
            }
        } else {
            self.picImageView.image = #imageLiteral(resourceName: "profilePlaceholder")
        }
    }
    
    func adjustContentLblHeight() {
        contentLblHCons.constant = doctorTypeLbl.sizeToFitHeight()
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
    
    func adjustAddressLblHeight() {
        addrLblHCons.constant = doctorAddrLbl.sizeToFitHeight()
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
    
    @IBAction func actionOnSendText(_ sender: UIButton) {
        if (delegate != nil) {
            self.delegate.actionOnSendText(btn: sender, indexPath: row, userImg: self.picImageView.image!)
        }
    }
}
