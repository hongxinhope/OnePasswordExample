//
//  Account.swift
//  OnePasswordExample
//
//  Created by 洪鑫 on 15/11/29.
//  Copyright © 2015年 Xin Hong. All rights reserved.
//

import UIKit

class Account: NSObject, NSCoding, NSCopying {
    private struct EncodeKeys {
        static let username = "username"
        static let password = "password"
        static let firstName = "firstName"
        static let lastName = "lastName"
    }
    
    var username: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    
    class func account(username username: String?, password: String?, firstName: String?, lastName: String?) -> Account {
        let account = Account()
        account.username = username
        account.password = password
        account.firstName = firstName
        account.lastName = lastName
        return account
    }
    
    override init() {
        
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copyAccount = Account.account(username: username, password: password, firstName: firstName, lastName: lastName)
        return copyAccount
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        username = aDecoder.decodeObjectForKey(EncodeKeys.username) as? String
        password = aDecoder.decodeObjectForKey(EncodeKeys.password) as? String
        firstName = aDecoder.decodeObjectForKey(EncodeKeys.firstName) as? String
        lastName = aDecoder.decodeObjectForKey(EncodeKeys.lastName) as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(username, forKey: EncodeKeys.username)
        aCoder.encodeObject(password, forKey: EncodeKeys.password)
        aCoder.encodeObject(firstName, forKey: EncodeKeys.firstName)
        aCoder.encodeObject(lastName, forKey: EncodeKeys.lastName)
    }
    
    func isValid() -> Bool {
        return username?.isEmpty == false && password?.isEmpty == false && firstName?.isEmpty == false && lastName?.isEmpty == false
    }
}
