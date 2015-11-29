//
//  Account.swift
//  OnePasswordExample
//
//  Created by 洪鑫 on 15/11/29.
//  Copyright © 2015年 Xin Hong. All rights reserved.
//

import UIKit

class Account: NSObject, NSCoding {
    private struct EncodeKeys {
        static let username = "username"
        static let password = "password"
    }
    
    var username: String?
    var password: String?
    
    class func account(username username: String?, password: String?) -> Account {
        let account = Account()
        account.username = username
        account.password = password
        return account
    }
    
    override init() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        username = aDecoder.decodeObjectForKey(EncodeKeys.username) as? String
        password = aDecoder.decodeObjectForKey(EncodeKeys.password) as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(username, forKey: EncodeKeys.username)
        aCoder.encodeObject(password, forKey: EncodeKeys.password)
    }
    
    func isValid() -> Bool {
        return username!.isEmpty == false && password!.isEmpty == false
    }
}
