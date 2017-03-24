//
//  DocTextApi.swift
//  Dr.Text
//
//  Created by SoftSuave on 15/12/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import Alamofire

class DocTextApi: NSObject {
    
    class func getRooms(senderId: String, completionHandler: @escaping ([Dictionary<String, AnyObject>]?, NSError?) -> ()) {
        let url = "\(BASE_URL)/getroom?senderid=\(senderId)"
        print("calling url: \(url)")
        Alamofire.request(url, method: .get).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? [Dictionary<String, AnyObject>] {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func invitePatient(doctorId: String, phoneNo: String, completionHandler: @escaping (String?, NSError?) -> ()) {
        let url = "\(BASE_URL)/invitedoctor?phoneno=\(phoneNo)&inviteto=Patient&doctorid=\(doctorId)"
        print("calling url: \(url)")
        Alamofire.request(url, method: .post).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? String {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func verifyDoctor(phoneNo: String, patientId: String, code: String, completionHandler: @escaping (Dictionary<String, AnyObject>?, NSError?) -> ()) {
        
        let url = "\(BASE_URL)/verifydoctor?phone=\(phoneNo)&patientid=\(patientId)&code=\(code)"
        print("calling url: \(url)")
        Alamofire.request(url, method: .put).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func updateUser(user: User, completionHandler: @escaping (String?, NSError?) -> ()) {
        let url = "\(BASE_URL)/updateuser"
        let params = ["userName": user.emailID!,
                      "firstName": user.firstName!,
                      "lastName": user.lastName!,
                      "profilePicUrl": user.profilePicUrl == nil ? "nil" : user.profilePicUrl!,
                      "dateOfBirth": user.dateOfBirth!,
                      "doctorTitle": user.doctorTitle!,
                      "doctorType": user.doctorType!,
                      "doctorCharge": user.doctorCharge!,
                      "doctor_addr_street": user.doctor_addr_street!,
                      "doctor_addr_unit": user.doctor_addr_unit!,
                      "doctor_addr_city": user.doctor_addr_city!,
                      "doctor_addr_state": user.doctor_addr_state!,
                      "doctor_addr_zip": user.doctor_addr_zip!,
                      "custom:doctor_office_phno": user.doctor_office_phno!]
        
        print("calling url: \(url)")
        print("params: \(params)")
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? String {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    
    class func getChatMessages(roomId: String, limit: String, evaluatedKeyDict: Dictionary<String, Any>?, completionHandler: @escaping (Dictionary<String, AnyObject>?, NSError?) -> ()) {

        let url = "\(BASE_URL)/getroomchats?roomId=\(roomId)"
        var params = Dictionary<String, Any?>()
        if let dict = evaluatedKeyDict {
            params = ["RoomId": roomId,
                      "Limit": limit,
                      "LastEvaluatedKey": dict]
        } else {
            params = ["RoomId": roomId,
                      "Limit": limit,
                      "LastEvaluatedKey": nil]
        }
        
        print("calling url: \(url)")
        print("params: \(params)")
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func saveDeviceToken(deviceToken: String, completionHandler: @escaping (Dictionary<String, Any>?, NSError?) -> ()) {
        let url = "\(BASE_URL)/savedevicetoken?userId=\(Utils.user.emailID!)&deviceToken=\(deviceToken)&deviceId=\(Utils.getDeviceId())"
        print("calling url: \(url)")
        Alamofire.request(url, method: .post).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func removeDeviceToken(completionHandler: @escaping (Dictionary<String, Any>?, NSError?) -> ()) {
        let url = "\(BASE_URL)/deletedevicetoken?userId=\(Utils.user.emailID!)&deviceId=\(Utils.getDeviceId())"
        print("calling url: \(url)")
        Alamofire.request(url, method: .delete).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }

    
    //MARK: Stripe Payment Apis...
    class func createStripeCustomer(customerId: String, expMonth: String, expYear: String, card_number: String, cvc: String, zipCode: String, completionHandler: @escaping (Dictionary<String, AnyObject>?, NSError?) -> ()) {
        
        let url = "\(BASE_URL)/createstripecustomer"
        let params = ["customerId": customerId,
                      "userId": Utils.getCurrentUser().emailID!,
                      "type": "card",
                      "exp_month": expMonth,
                      "exp_year": expYear,
                      "card_number": card_number,
                      "cvc": cvc,
                      "zip_code": zipCode]
        print("calling url: \(url)")
        print("params: \(params)")
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func getCardDetails(customerId: String, cardId: String, completionHandler: @escaping (Dictionary<String, AnyObject>?, NSError?) -> ()) {
        
        let url = "\(BASE_URL)/getcarddetails"
        let params = ["customerId": "\(customerId)", "cardId": cardId]
        print("calling url: \(url)")
        print("params: \(params)")
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func makePayment(customerId: String, amount: String, completionHandler: @escaping (Dictionary<String, AnyObject>?, NSError?) -> ()) {
        
        let url = "\(BASE_URL)/makepayment"
        let params = ["customerId": "\(customerId)",
                      "amount": String(Int(amount)! * 100),
                      "currency": AMOUNT_CURRENCY]
        print("calling url: \(url)")
        print("params: \(params)")
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            print("Response: \(response )")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }

    class func updateCardDetails(zipCode: String, expMonth: String, expYear: String, completionHandler: @escaping (Dictionary<String, AnyObject>?, NSError?) -> ()) {
        
        let url = "\(BASE_URL)/updatecard"
        let params = ["customerId": Utils.user.customerId!,
                      "cardId": Utils.user.cardId!,
                      "zip_code": zipCode,
                      "exp_month": expMonth,
                      "exp_year": expYear,
                      "name": "\(Utils.user.firstName!) \(Utils.user.lastName!)"]
        print("calling url: \(url)")
        print("params: \(params)")
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func getUserDetails(userId: String, completionHandler: @escaping (Dictionary<String, Any>?, NSError?) -> ()) {
        let url = "\(BASE_URL)/getuser?userId=\(userId)"
        print("calling url: \(url)")
        Alamofire.request(url, method: .get).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func checkUserExistOrNot(emailID: String, completionHandler: @escaping (Dictionary<String, Any>?, NSError?) -> ()) {
        let url = "\(BASE_URL)/checkemailexist?emailId=\(emailID)"
        print("calling url: \(url)")
        Alamofire.request(url, method: .get).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func updateMessageStatus(messageIds: [String], roomId: String, messageStatus: String, completionHandler: @escaping (Dictionary<String, Any>?, NSError?) -> ()) {
        let url = "\(BASE_URL)/updatemessagestatus"
        let params = ["messageStatus": messageStatus,
                      "roomId": roomId,
                      "messageIds": messageIds] as [String : Any]
        print("calling url: \(url)")
        print("params: \(params)")
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    class func createRoom(docId: String, docFirstName: String, docLastName: String, docProfilePic: String, completionHandler: @escaping (Dictionary<String, Any>?, NSError?) -> ()) {
        let url = "\(BASE_URL)/createroom"
        let params = ["doctor": ["id": docId,
                                 "firstName": docFirstName,
                                 "lastName": docLastName,
                                 "profilePicUrl": docProfilePic],
                      "patient": ["id": Utils.user.emailID!,
                                  "firstName": Utils.user.firstName!,
                                  "lastName": Utils.user.lastName!,
                                  "profilePicUrl": Utils.user.profilePicUrl == nil ? "nil" : Utils.user.profilePicUrl!]]
        print("calling url: \(url)")
        print("params: \(params)")
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            print("Response: \(response)")
            switch response.result {
            case .success(let value):
                if let jsonResult = value as? Dictionary<String, AnyObject> {
                    completionHandler(jsonResult, nil)
                } else {
                    completionHandler(nil, nil)
                }
                
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
}
