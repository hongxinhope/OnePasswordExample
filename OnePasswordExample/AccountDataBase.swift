//
//  AccountDataBase.swift
//  OnePasswordExample
//
//  Created by 洪鑫 on 15/11/29.
//  Copyright © 2015年 Xin Hong. All rights reserved.
//

import UIKit

class AccountDataBase: NSObject {
    private struct UserDefaultsKey {
        static let onePasswordExampleAccount = "onePasswordExampleAccount"
    }
    
    class func accounts() -> [Account]? {
        if let accountDataArray = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.onePasswordExampleAccount) as? [NSData] {
            var accounts = [Account]()
            for accountData in accountDataArray {
                if let account = NSKeyedUnarchiver.unarchiveObjectWithData(accountData) as? Account {
                    accounts.append(account)
                }
            }
            
            return accounts
        }
        return nil
    }
    
    class func fetchAccount(username username: String) -> Account? {
        if let accounts = accounts() {
            for account in accounts {
                if account.username == username {
                    return account
                }
            }
        }
        return nil
    }
    
    class func updateAccount(username username:String, newAccount: Account, success: Void -> Void, failure: Void -> Void) {
        if !newAccount.isValid() {
            failure()
            return
        }
        
        let newAccountData = NSKeyedArchiver.archivedDataWithRootObject(newAccount)
        
        if let accounts = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.onePasswordExampleAccount) as? [NSData] {
            var accountDataArray = accounts
            
            for (index, accountData) in accountDataArray.enumerate() {
                if let account = NSKeyedUnarchiver.unarchiveObjectWithData(accountData) as? Account {
                    if account.username == username {
                        accountDataArray.removeAtIndex(index)
                        break
                    }
                }
            }
            
            accountDataArray.append(newAccountData)
            NSUserDefaults.standardUserDefaults().setValue(accountDataArray, forKey: UserDefaultsKey.onePasswordExampleAccount)
        }
        
        success()
    }
    
    class func storeAccount(account: Account, success: Void -> Void, failure: Void -> Void) {
        if !account.isValid() {
            failure()
            return
        }
        
        let accountData = NSKeyedArchiver.archivedDataWithRootObject(account)
        
        if let accounts = NSUserDefaults.standardUserDefaults().valueForKey(UserDefaultsKey.onePasswordExampleAccount) as? [NSData] {
            var accountsArray = accounts
            accountsArray.append(accountData)
            NSUserDefaults.standardUserDefaults().setValue(accountsArray, forKey: UserDefaultsKey.onePasswordExampleAccount)
        } else {
            let accounts = [accountData]
            NSUserDefaults.standardUserDefaults().setValue(accounts, forKey: UserDefaultsKey.onePasswordExampleAccount)
        }
        
        success()
    }
    
    class func accountExistent(username username: String) -> Bool {
        if let _ = fetchAccount(username: username) {
            return true
        }
        return false
    }
    
    class func accountAuthenticated(account account: Account) -> (authenticated: Bool, account: Account?) {
        if let storedAccount = fetchAccount(username: account.username!) {
            if account.password == storedAccount.password {
                return (true, storedAccount)
            }
        }
        return (false, nil)
    }
}
