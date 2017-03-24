//
//  CustomIdentityProvider.swift
//  Dr.Text
//
//  Created by SoftSuave on 17/10/16.
//  Copyright © 2016 SoftSuave. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class CustomIdentityProvider: NSObject, AWSIdentityProviderManager {
    var tokens : [String : String]
    
    init(tokens: [String : String]) {
        self.tokens = tokens
    }
    
    public func logins() -> AWSTask<NSDictionary> {
        return AWSTask(result: tokens as NSDictionary)
    }
}
