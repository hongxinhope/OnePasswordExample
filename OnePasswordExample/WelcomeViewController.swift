//
//  WelcomeViewController.swift
//  OnePasswordExample
//
//  Created by 洪鑫 on 15/11/29.
//  Copyright © 2015年 Xin Hong. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var loginAccount: Account!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Helper
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "didClickCancel:")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change Password", style: .Done, target: self, action: "didClickChangePassword:")
        welcomeLabel.font = UIFont(name: "HelveticaNeue-Light", size: 40)
        welcomeLabel.text = "Welcome \(loginAccount.firstName!) \(loginAccount.lastName!),\ryou have signed in successfully!"
    }
    
    // MARK: - Selector
    func didClickCancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didClickChangePassword(sender: UIBarButtonItem) {
        
    }
}
