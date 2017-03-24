//
//  Conversation.swift
//  Dr.Text
//
//  Created by SoftSuave on 17/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class Conversation: NSObject {
    
    var chatRoomId: String?
    var patientId: String?
    var doctorId: String?
    var patientName: String?
    var doctorName: String?
    var roomName: String?
    var active: String?
    var createTime: String?
    var lastMessage: String?
    var lastMessageTime: String?
    var messageStatus: String?
    var convImage: UIImage?
    var convImageUrl: String?
    var unreadCount: Int?
    var userDetails: User?
}
