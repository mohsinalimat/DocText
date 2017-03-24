//
//  MessageEntity.swift
//  Dr.Text
//
//  Created by SoftSuave on 14/11/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import CoreData
import JSQMessagesViewController
@objc(MessageEntity)

class MessageEntity: NSManagedObject {
    
    @NSManaged var message_id: String?
    @NSManaged var message_type: String?
    @NSManaged var message_status: String?
    @NSManaged var transactionId: String?
    @NSManaged var payment_status: String?
    @NSManaged var message: String?
    @NSManaged var room_id: String?
    @NSManaged var sender_id: String?
    @NSManaged var receiver_id: String?
    @NSManaged var sent_time: String?
    @NSManaged var media_url: String?
    @NSManaged var media: Data?
    @NSManaged var videoLocalUrl: String?
    
    func getMessageList(messageEntity: MessageEntity) -> Message {
        
        var message: Message? = nil
        if messageEntity.message_type == MEDIA_TYPE_TEXT {
            message = Message(messageId: messageEntity.message_id,
                              message: messageEntity.message,
                              messageType: messageEntity.message_type,
                              senderId: messageEntity.sender_id,
                              roomId: messageEntity.room_id,
                              sendTimeString: messageEntity.sent_time,
                              sendTimeobject: nil,
                              receiverId: messageEntity.receiver_id,
                              message_status: messageEntity.message_status!,
                              paymentStatus: messageEntity.payment_status!,
                              transactionId: messageEntity.transactionId!)
        } else if messageEntity.message_type == MEDIA_TYPE_IMAGE {
            if let url = messageEntity.videoLocalUrl {
            let photoItem = JSQPhotoMediaItem(image: UIImage(data:messageEntity.media!,scale:1.0))
            message = Message(messageId: messageEntity.message_id,
                              message: messageEntity.message,
                              messageType: messageEntity.message_type,
                              senderId: messageEntity.sender_id,
                              roomId:  messageEntity.room_id,
                              sendTimeString: messageEntity.sent_time,
                              sendTimeobject: nil,
                              media: photoItem,
                              media_Msg_Data: messageEntity.media,
                              mediaUrl: messageEntity.media_url,
                              receiverId: messageEntity.receiver_id,
                              message_status: messageEntity.message_status!,
                              thumbnailImage: nil,
                              videoLocalUrl: url,
                              paymentStatus: messageEntity.payment_status!,
                              transactionId: messageEntity.transactionId!)
            } else {
                let photoItem = JSQPhotoMediaItem(image: UIImage(data:messageEntity.media!,scale:1.0))
                message = Message(messageId: messageEntity.message_id,
                                  message: messageEntity.message,
                                  messageType: messageEntity.message_type,
                                  senderId: messageEntity.sender_id,
                                  roomId:  messageEntity.room_id,
                                  sendTimeString: messageEntity.sent_time,
                                  sendTimeobject: nil,
                                  media: photoItem,
                                  media_Msg_Data: messageEntity.media,
                                  mediaUrl: messageEntity.media_url,
                                  receiverId: messageEntity.receiver_id,
                                  message_status: messageEntity.message_status!,
                                  thumbnailImage: nil,
                                  videoLocalUrl: nil,
                                  paymentStatus: messageEntity.payment_status!,
                                  transactionId: messageEntity.transactionId!)
            }
        } else if messageEntity.message_type == MEDIA_TYPE_VIDEO {
            if let url = messageEntity.videoLocalUrl {
                let videoURL = URL(string: url)
                let videoItem = DrTextJSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
                message = Message(messageId: messageEntity.message_id,
                                  message: messageEntity.message,
                                  messageType: messageEntity.message_type,
                                  senderId: messageEntity.sender_id,
                                  roomId:  messageEntity.room_id,
                                  sendTimeString: messageEntity.sent_time,
                                  sendTimeobject: nil,
                                  media: videoItem,
                                  media_Msg_Data: messageEntity.media,
                                  mediaUrl: messageEntity.media_url,
                                  receiverId: messageEntity.receiver_id,
                                  message_status: messageEntity.message_status!,
                                  thumbnailImage: nil,
                                  videoLocalUrl: messageEntity.videoLocalUrl,
                                  paymentStatus: messageEntity.payment_status!,
                                  transactionId: messageEntity.transactionId!)
            } else {
                message = Message(messageId: messageEntity.message_id,
                                  message: messageEntity.message,
                                  messageType: messageEntity.message_type,
                                  senderId: messageEntity.sender_id,
                                  roomId:  messageEntity.room_id,
                                  sendTimeString: messageEntity.sent_time,
                                  sendTimeobject: nil,
                                  media: JSQPhotoMediaItem(image: #imageLiteral(resourceName: "placeholder")),
                                  media_Msg_Data: UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder")),
                                  mediaUrl: messageEntity.media_url,
                                  receiverId: messageEntity.receiver_id,
                                  message_status: messageEntity.message_status!,
                                  thumbnailImage: #imageLiteral(resourceName: "placeholder"),
                                  videoLocalUrl: nil,
                                  paymentStatus: messageEntity.payment_status!,
                                  transactionId: messageEntity.transactionId!)
            }
        }  else if messageEntity.message_type == MEDIA_TYPE_AUDIO {
            
            if messageEntity.videoLocalUrl != nil {
                message = Message(messageId: messageEntity.message_id,
                                  message: messageEntity.message,
                                  messageType: messageEntity.message_type,
                                  senderId: messageEntity.sender_id,
                                  roomId:  messageEntity.room_id,
                                  sendTimeString: messageEntity.sent_time,
                                  sendTimeobject: nil,
                                  media: JSQAudioMediaItem(data: messageEntity.media),
                                  media_Msg_Data: messageEntity.media,
                                  mediaUrl: messageEntity.media_url,
                                  receiverId: messageEntity.receiver_id,
                                  message_status: messageEntity.message_status!,
                                  thumbnailImage: nil,
                                  videoLocalUrl: messageEntity.videoLocalUrl,
                                  paymentStatus: messageEntity.payment_status!,
                                  transactionId: messageEntity.transactionId!)
            } else {
                message = Message(messageId: messageEntity.message_id,
                                  message: messageEntity.message,
                                  messageType: messageEntity.message_type,
                                  senderId: messageEntity.sender_id,
                                  roomId:  messageEntity.room_id,
                                  sendTimeString: messageEntity.sent_time,
                                  sendTimeobject: nil,
                                  media: JSQAudioMediaItem(data: nil),
                                  media_Msg_Data: nil,
                                  mediaUrl: messageEntity.media_url,
                                  receiverId: messageEntity.receiver_id,
                                  message_status: messageEntity.message_status!,
                                  thumbnailImage: nil,
                                  videoLocalUrl: nil,
                                  paymentStatus: messageEntity.payment_status!,
                                  transactionId: messageEntity.transactionId!)
            }
        }
        return message!
    }
    
    func setMessageList(messageEntity: MessageEntity,messageModel: Message) {
        
        messageEntity.message_id = messageModel.message_id
        messageEntity.message_type = messageModel.message_type
        messageEntity.message = messageModel.message
        messageEntity.room_id = messageModel.room_id
        messageEntity.sender_id = messageModel.sender_Id
        messageEntity.sent_time = messageModel.sent_time
        messageEntity.media_url = messageModel.media_url
        messageEntity.message_status = messageModel.message_status
        messageEntity.videoLocalUrl = messageModel.videoLocalUrl
        messageEntity.receiver_id = messageModel.receiver_Id
        messageEntity.payment_status = messageModel.payment_status
        messageEntity.transactionId = messageModel.transactionId
        
        if messageModel.message_type != MEDIA_TYPE_TEXT {
            messageEntity.media = messageModel.media_Msg_Data
        }
    }
}
