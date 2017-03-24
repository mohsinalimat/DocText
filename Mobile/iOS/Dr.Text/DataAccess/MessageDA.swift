//
//  MessageDA.swift
//  Dr.Text
//
//  Created by SoftSuave on 14/11/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import CoreData
import JSQMessagesViewController

class MessageDA: NSObject {
    
    let managedObjectContext  = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Add Messages
    func addMessage(messageModel: Message) {
        
        let messageEntity = NSEntityDescription.insertNewObject(forEntityName: "MessageEntity", into: managedObjectContext) as! MessageEntity
        
        messageEntity.setMessageList(messageEntity: messageEntity, messageModel: messageModel)
        self.save()
    }
    
    //MARK: Fetch Messages
    func fetchMessageList(roomId: String, offset: Int) -> [Message] {
        
        if Utils.currentChatMessages.count == 0 {
            Utils.currentChatMessages = self.fetchAllMessages(roomId: roomId)
            return arrangeMsg(offset: offset)
        } else {
            return arrangeMsg(offset: offset)
        }
    }
    
    func arrangeMsg(offset: Int) -> [Message] {
        var total = 0
        if Utils.currentChatMessages.count != 0 {
            if (Utils.currentChatMessages.count - offset) >= 30 {
                total = offset + 29
            } else {
                total = Utils.currentChatMessages.count - 1
            }
            
            let messages = Array(Utils.currentChatMessages.reversed()[offset...total]) as [Message]
            return messages.reversed()
        } else {
            return Utils.currentChatMessages
        }
    }
    
    //MARK: Get message count
    func getMessagesCount(roomId: String) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        let perdicate = NSPredicate(format:"room_id=%@ AND payment_status == %@", roomId, "Paid")
        fetchRequest.predicate = perdicate
        
        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) {
            return fetchResults.count
        }
        
        return 0
    }
    
    
    //MARK: Fetch Unread Messages
    func fetchUnReadMessageList() -> ([Message],[String]) {
        let status = !Utils.IsCurrentUserIsPatient() ? "Not delivered" : "Sent"
        var messageList : [Message] = [Message]()
        var messageIdsList : [String] = [String]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        let perdicate = NSPredicate(format:"message_status == %@", status)
        fetchRequest.predicate = perdicate
        
        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) {
            if(fetchResults.count > 0) {
                for obj in fetchResults {
                    let messageEntity = obj as! MessageEntity
                    let message = messageEntity.getMessageList(messageEntity: messageEntity)
                    messageIdsList.append(message.message_id!)
                    messageList.append(message)
                }
            }
        }
        return (messageList, messageIdsList)
    }
    
    //MARK: Fetch All Messages
    func fetchAllMessages(roomId: String) -> [Message] {
        
        var messageList : [Message] = [Message]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        let perdicate = NSPredicate(format:"room_id=%@ AND payment_status == %@", roomId, "Paid")
        fetchRequest.predicate = perdicate
        
        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) {
            if(fetchResults.count > 0) {
                for obj in fetchResults {
                    let messageEntity = obj as! MessageEntity
                    messageList.append(messageEntity.getMessageList(messageEntity: messageEntity))
                }
            }
        }
        
        messageList.sort(by: { Utils.convertDateStringForDate(dateString: $0.sent_time!).compare(Utils.convertDateStringForDate(dateString: $1.sent_time!)) == .orderedAscending})
        
        return messageList
    }
    
    
    //MARK: Fetch unsent Messages
    func fetchUnSentMessageList() -> [Message] {
        
        var messageList : [Message] = [Message]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        let perdicate = NSPredicate(format:"message_status == %@ AND payment_status == %@", MESSAGE_STATUS_NOT_SENT, "Paid")
        fetchRequest.predicate = perdicate
        
        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) {
            if(fetchResults.count > 0) {
                for obj in fetchResults {
                    let messageEntity = obj as! MessageEntity
                    messageList.append(messageEntity.getMessageList(messageEntity: messageEntity))
                }
            }
        }
        return messageList
    }
    
    
    //MARK: Fetch Specific Message
    func fetchMessageWith(sentTime: String) -> Message? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        let perdicate = NSPredicate(format:"sent_time=%@", sentTime)
        fetchRequest.predicate = perdicate
        
        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) {
            if(fetchResults.count > 0) {
                for obj in fetchResults {
                    let messageEntity = obj as! MessageEntity
                    return messageEntity.getMessageList(messageEntity: messageEntity)
                }
            }
        }
        
        return nil
    }
    
    
    //MARK: Delete All Messages
    func deleteMessages() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) {
            for managedObject: Any in fetchResults {
                managedObjectContext.delete(managedObject as! NSManagedObject)
                self.save()
            }
            
        }
    }
    
    
    //MARK: Delete sent Messages
    func deletesentMessages() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        let perdicate = NSPredicate(format:"message_status == sent")
        fetchRequest.predicate = perdicate
        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) {
            for managedObject: Any in fetchResults {
                managedObjectContext.delete(managedObject as! NSManagedObject)
                self.save()
            }
            
        }
    }
    
    
    //MARK: Add or Update Message
    func addUpdateMessages(message: Message) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        let perdicate = NSPredicate(format:"sent_time=%@", message.sent_time!)
        fetchRequest.predicate = perdicate
        
        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) {
            if(fetchResults.count > 0) {
                for path:Any in fetchResults {
                    let messageEntity =  path as! MessageEntity
                    messageEntity.setMessageList(messageEntity: messageEntity, messageModel: message)
                    self.save()
                }
            } else {
                self.addMessage(messageModel: message)
            }
        }
    }
    
    //MARK: - Save to CoreData
    func save() {
        do {
            try managedObjectContext.save()
        } catch _ {
            print("Exception found...")
        }
    }
}
