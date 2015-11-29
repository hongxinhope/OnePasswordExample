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
    
    var username: String!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Helper
    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "didClickDone:")
        welcomeLabel.font = UIFont(name: "HelveticaNeue-Light", size: 40)
        welcomeLabel.text = "Welcome \(username),\ryou have signed in successfully!"
    }
    
    // MARK: - Selector
    func didClickDone(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
