//
//  User.swift
//  Dr.Text
//
//  Created by SoftSuave on 12/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit

class User: NSObject {

    var id: String?
    var name: String?
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var emailID: String?
    var userRole: String?
    var isEmailVerified: Bool?
    var isPhNoVerified: Bool?
    var image: UIImage?
    var profilePicUrl: String?
    var dateOfBirth: String?
    var doctorTitle: String?
    var doctorType: String?
    var doctorCharge: String?
    var phCountryCode: String?
    var doctor_addr_street: String?
    var doctor_addr_unit: String?
    var doctor_addr_city: String?
    var doctor_addr_state: String?
    var doctor_addr_zip: String?
    var doctor_office_phno: String?
    var customerId: String?
    var cardId: String?
    var cardBrand: String?
    var cardLastFourDigit: String?
    var cardExpMonth: Int?
    var cardExpYear: Int?
    var cardZipCode: String?
    var iSCardWorking = false
}
