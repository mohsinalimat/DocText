//
//  Message.swift
//  Dr.Text
//
//  Created by SoftSuave on 17/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSDynamoDB
import JSQMessagesViewController

class Message: AWSDynamoDBObjectModel, AWSDynamoDBModeling, JSQMessageData {
    
    var message_id: String?
    var message: String?
    var message_type: String?
    var payment_status: String?
    var transactionId: String?
    var sent_time: String?
    var sender_Id: String?
    var receiver_Id: String?
    var room_id: String?
    var media_url: String?
    var media_Data: JSQMessageMediaData?
    var media_Msg_Data: Data?
    var senderDisplayName_ = ""
    var isMediaMessage_: Bool?
    var send_time_Date_object: Date?
    var message_status: String?
    var thumbnailImage: UIImage?
    var videoLocalUrl: String?

    init(messageId: String?, message: String?, messageType: String?, senderId: String?, roomId: String?, sendTimeString: String?, sendTimeobject: Date?, receiverId: String?, message_status: String,paymentStatus: String,transactionId: String) {
        super.init()
        self.message = message
        self.message_id = messageId
        self.message_type = messageType
        self.sent_time = sendTimeString
        self.send_time_Date_object = sendTimeobject
        self.room_id = roomId
        self.sender_Id = senderId
        self.receiver_Id = receiverId
        self.message_status = message_status
        self.payment_status = paymentStatus
        self.transactionId = transactionId
    }
    
    init(messageId: String?, message: String?, messageType: String?, senderId: String?, roomId: String?, sendTimeString: String?, sendTimeobject: Date?, media: JSQMessageMediaData?, media_Msg_Data: Data?, mediaUrl: String?, receiverId: String?, message_status: String, thumbnailImage: UIImage?, videoLocalUrl: String?,paymentStatus: String,transactionId: String) {
        super.init()
        self.message = message
        self.message_id = messageId
        self.message_type = messageType
        self.sent_time = sendTimeString
        self.send_time_Date_object = sendTimeobject
        self.room_id = roomId
        self.sender_Id = senderId
        self.media_Msg_Data = media_Msg_Data
        self.media_Data = media
        self.media_url = mediaUrl
        self.receiver_Id = receiverId
        self.message_status = message_status
        self.thumbnailImage = thumbnailImage
        self.videoLocalUrl = videoLocalUrl
        self.payment_status = paymentStatus
        self.transactionId = transactionId
        
        if self.message_type == MEDIA_TYPE_TEXT {
            isMediaMessage_ = false
        } else {
            isMediaMessage_ = true
        }

    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func dynamoDBTableName() -> String {
        return "lambdachat"
    }
    
    static func hashKeyAttribute() -> String {
        return "message_id"
    }
    
    
    func text() -> String? {
        return message
    }
    
    func senderId() -> String? {
        return sender_Id
    }
    
    func date() -> Date? {
        return send_time_Date_object as Date?
    }
    
    func senderDisplayName() -> String? {
        return senderDisplayName_
    }
    
    func isMediaMessage() -> Bool {
        
        if self.message_type == MEDIA_TYPE_TEXT {
            return false
        } else {
            return true
        }
    }
    
    func messageHash() -> UInt {
        return UInt(abs(self.hash))
    }
    
    func media() -> JSQMessageMediaData! {
        return media_Data
    }
}

class LastEvaluatedKey: NSObject {
    var message_id: String?
    var room_id: String?
    var server_time: String?
}
