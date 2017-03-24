//
//  DrTextJSQVideoMediaItem.swift
//  Dr.Text
//
//  Created by SoftSuave on 23/11/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class DrTextJSQVideoMediaItem: JSQVideoMediaItem {
    
    override func mediaView() -> UIView! {
        if self.fileURL == nil || !self.isReadyToPlay {
            return nil
        }
        
        let size = self.mediaViewDisplaySize()

        let imgView = UIImageView(image: #imageLiteral(resourceName: "Videoplay"))
        imgView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        imgView.contentMode = .center
        imgView.clipsToBounds = true
        imgView.backgroundColor = UIColor.clear
        JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imgView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
        
        let thumbnail = UIImageView(image: #imageLiteral(resourceName: "placeholder"))
        if Utils.thumbnailForVideoAtURL(url: self.fileURL) != nil {
            thumbnail.image = Utils.thumbnailForVideoAtURL(url: self.fileURL)!
        }
            thumbnail.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            thumbnail.contentMode = .scaleAspectFill
            thumbnail.clipsToBounds = true
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: thumbnail, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            thumbnail.addSubview(imgView)
        
        return thumbnail
    }
}
