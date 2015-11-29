//
//  AccountsViewController.swift
//  OnePasswordExample
//
//  Created by 洪鑫 on 15/11/29.
//  Copyright © 2015年 Xin Hong. All rights reserved.
//

import UIKit

class AccountsViewController: UITableViewController {
    // MARK: - Structs
    private struct Identifiers {
        static let accountCellIdentifier = "AccountCell"
    }
    
    // MARK: - Properties
    var accountsData = [Account]()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadData()
    }
    
    // MARK: - Helper
    private func setupUI() {
        navigationItem.title = "Registered Users"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "didClickCancel:")
    }
    
    private func loadData() {
        if let accounts = AccountDataBase.accounts() {
            accountsData = accounts
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return accountsData.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return 5
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.accountCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: Identifiers.accountCellIdentifier)
        }
        cell!.accessoryType = .None
        cell!.selectionStyle = .None
        cell!.textLabel!.font = UIFont.systemFontOfSize(16)
        
        let account = accountsData[indexPath.section]
        if indexPath.row == 0 {
            if let firstName = account.firstName, lastName = account.lastName {
                cell!.textLabel!.text = "Name: \(firstName) \(lastName)"
            }
        } else if indexPath.row == 1 {
            if let username = account.username {
                cell!.textLabel!.text = "Username: \(username)"
            }
        } else if indexPath.row == 2 {
            if let password = account.password {
                cell!.textLabel!.text = "Password: \(password)"
            }
        }
        
        return cell!
    }
    
    // MARK: - Selector
    func didClickCancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
