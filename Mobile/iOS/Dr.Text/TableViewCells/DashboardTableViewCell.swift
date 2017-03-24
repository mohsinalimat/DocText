//
//  DashboardTableViewCell.swift
//  Dr.Text
//
//  Created by SoftSuave on 17/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import SDWebImage

class DashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLblHCons: NSLayoutConstraint!
    @IBOutlet weak var contentLblBCons: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var picOutterView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.width / 2

        picOutterView.layer.masksToBounds = true
        picOutterView.layer.cornerRadius = picOutterView.frame.width / 2
    }
    
    func adjustContentLblHeight() {
        contentLblHCons.constant = contentLabel.sizeToFitHeight()
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
    
    // Download Image with Progress
    func downloadProfilePic(url: String?) {
        if let picUrl = url {
            if !FileUtils.IsImageFileExists(fileName: picUrl) {
            SDWebImageManager.shared().downloadImage(with: NSURL(string: picUrl) as URL!, options: [.continueInBackground, .lowPriority], progress: { (min, max) in
                print("downloading progress \(min) and \(max)")
            }, completed: { (image, error, type, finished, url) in
                if image != nil {
                    self.userImageView.image = image
                    FileUtils.saveImageAtFileName(image: image!, fileName: (url?.absoluteString)!)
                } else {
                    print("Image Download error found: \(error)")
                }
            })
            } else {
                self.userImageView.image = FileUtils.getImage(fileName: picUrl)
            }

        } else {
            self.userImageView.image = #imageLiteral(resourceName: "profilePlaceholder")
        }
    }
}

extension UILabel {
    
    func sizeToFitHeight() -> CGFloat {
        let size:CGSize = self.sizeThatFits(CGSize(width:self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        return size.height
    }
}
