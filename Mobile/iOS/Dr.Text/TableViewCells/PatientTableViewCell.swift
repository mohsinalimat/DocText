//
//  PatientTableViewCell.swift
//  Dr.Text
//
//  Created by SoftSuave on 11/01/13.
//  Copyright © 2013 SoftSuave. All rights reserved.
//

import UIKit
import SDWebImage

protocol patientTableViewCellDelegate {
    func actionOnSendText(btn: UIButton, indexPath: Int, userImg: UIImage)
}

class PatientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var picImageView: UIImageView!
    @IBOutlet weak var sendTextBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phoneNoLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    var row: Int!
    var delegate: patientTableViewCellDelegate!
    var roomID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        picImageView.layer.masksToBounds = true
        picImageView.layer.cornerRadius = picImageView.frame.size.width / 2
        picImageView.layer.borderWidth = 3.0
        picImageView.layer.borderColor = UIColor.white.cgColor
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
    
    @IBAction func actionOnSendText(_ sender: UIButton) {
        if (delegate != nil) {
            self.delegate.actionOnSendText(btn: sender, indexPath: row, userImg: self.picImageView.image!)
        }
    }
}
