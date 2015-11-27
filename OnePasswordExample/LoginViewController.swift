//
//  LoginViewController.swift
//  OnePasswordExample
//
//  Created by 洪鑫 on 15/11/27.
//  Copyright © 2015年 Xin Hong. All rights reserved.
//

import UIKit
import OnePasswordExtension

class Account: NSObject {
    var username: String?
    var password: String?
    
    class func account(username username: String?, password: String?) -> Account {
        let account = Account()
        account.username = username
        account.password = password
        return account
    }
}

class LoginViewController: UIViewController {
    // MARK: - Structs and enums
    enum UserInterfaceMode: Int {
        case Signin
        case Signup
    }
    
    private struct Selectors {
        static let resignFirstResponder: Selector = "resignFirstResponder"
        static let didClick1PasswordIcon: Selector = "didClick1PasswordIcon:"
    }
    
    private struct UserDefaultsKey {
        static let onePasswordExampleAccount = "onePasswordExampleAccount"
    }
    
    // MARK: - Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var onePasswordButton: UIButton!
    
    private var userInterfaceMode = UserInterfaceMode.Signin {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Helper
    private func setupUI() {
        userInterfaceMode = .Signin
        usernameTextField.enablesReturnKeyAutomatically = true
        passwordTextField.enablesReturnKeyAutomatically = true
    }
    
    private func updateUI() {
        if userInterfaceMode == .Signin {
            signinButton.setTitle("Sign in", forState: .Normal)
            reminderLabel.text = "Don't have an account?"
            signupButton.setTitle("Sign up", forState: .Normal)
        } else if userInterfaceMode == .Signup {
            signinButton.setTitle("Sign up", forState: .Normal)
            reminderLabel.text = "Already have an account?"
            signupButton.setTitle("Sign in", forState: .Normal)
        }
        
        passwordTextField.secureTextEntry = userInterfaceMode == .Signin
        onePasswordButton.hidden = userInterfaceMode == .Signup
        view.layoutIfNeeded()
    }
    
    private func show1PasswordUnavailableAlert() {
        let alert = UIAlertController(title: nil, message: "1Password is not installed on this device", preferredStyle: .Alert)
        let onePasswordAction = UIAlertAction(title: "Get 1Password", style: .Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/ca/app/1password-password-manager/id568903335?mt=8")!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(onePasswordAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func showReminderAlert(title title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func hideKeyboard() {
        UIApplication.sharedApplication().sendAction(Selectors.resignFirstResponder, to: nil, from: nil, forEvent: nil)
    }

    // MARK: - Selector
    @IBAction func didClickSigninButton(sender: UIButton) {
        if userInterfaceMode == .Signin {
            signin(username: usernameTextField.text!, password: passwordTextField.text!)
        } else if userInterfaceMode == .Signup {
            signup(username: usernameTextField.text!, password: passwordTextField.text!)
        }
    }

    @IBAction func didClickSignupButton(sender: UIButton) {
        if userInterfaceMode == .Signin {
            userInterfaceMode = .Signup
        } else if userInterfaceMode == .Signup {
            userInterfaceMode = .Signin
        }
    }
    
    @IBAction func touchDownBackgroundView(sender: UIControl) {
        hideKeyboard()
    }
    
    @IBAction func touchDownContentView(sender: UIControl) {
        hideKeyboard()
    }
    
    @IBAction func didClick1PasswordIcon(sender: UIButton) {
        if !OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
            show1PasswordUnavailableAlert()
            return
        }
    }
    
    // MARK: - Account
    private func accountKey(username username: String) -> String {
        return UserDefaultsKey.onePasswordExampleAccount + "_" + username
    }
    
    private func signin(username username: String, password: String) {
        
    }
    
    private func signup(username username: String, password: String) {
        let account = Account.account(username: username, password: password)
        let key = accountKey(username: username)
        NSUserDefaults.standardUserDefaults().setValue(account, forKey: key)
        
        showReminderAlert(title: nil, message: "Successfully signed up “\(username)”")
    }
}

