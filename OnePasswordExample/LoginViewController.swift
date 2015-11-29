//
//  LoginViewController.swift
//  OnePasswordExample
//
//  Created by 洪鑫 on 15/11/27.
//  Copyright © 2015年 Xin Hong. All rights reserved.
//

import UIKit
import OnePasswordExtension

class LoginViewController: UIViewController {
    // MARK: - Structs and enums
    enum UserInterfaceMode: Int {
        case Signin
        case Signup
    }
    
    private struct Selectors {
        static let resignFirstResponder: Selector = "resignFirstResponder"
        static let didClick1PasswordIcon: Selector = "didClick1PasswordIcon:"
        static let textFieldDidChange: Selector = "accountTextFieldDidChange:"
    }
    
    private struct StoryboardID {
        static let accountsViewController = "AccountsViewController"
        static let welcomeViewController = "WelcomeViewController"
    }
    
    private struct Colors {
        static let buttonEnabledColor = UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)
        static let buttonDisabledColor = UIColor(white: 190 / 255, alpha: 1)
    }
    
    // MARK: - Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var onePasswordButton: UIButton!
    @IBOutlet weak var loginFailedView: UIView!
    
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Helper
    private func setupUI() {
        userInterfaceMode = .Signin
        resetUI()
        
        usernameTextField.enablesReturnKeyAutomatically = true
        passwordTextField.enablesReturnKeyAutomatically = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selectors.textFieldDidChange, name: UITextFieldTextDidChangeNotification, object: usernameTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selectors.textFieldDidChange, name: UITextFieldTextDidChangeNotification, object: passwordTextField)
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
        
        resetUI()
        passwordTextField.secureTextEntry = userInterfaceMode == .Signin
        onePasswordButton.hidden = userInterfaceMode == .Signup
        view.layoutIfNeeded()
    }
    
    private func resetUI() {
        hideKeyboard()
        usernameTextField.text = nil
        passwordTextField.text = nil
        setSigninButtonEnabled(enabled: false)
        loginFailedView.hidden = true
    }
    
    private func setSigninButtonEnabled(enabled enabled: Bool) {
        signinButton.enabled = enabled
        if signinButton.enabled {
            signinButton.backgroundColor = Colors.buttonEnabledColor
        } else {
            signinButton.backgroundColor = Colors.buttonDisabledColor
        }
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
    
    @IBAction func didClickForgetPassword(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let accountsViewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardID.accountsViewController) as! AccountsViewController
        let navigationController = UINavigationController(rootViewController: accountsViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - TextField observer
    func accountTextFieldDidChange(notification: NSNotification) {
        loginFailedView.hidden = true
        let enabled = usernameTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
        setSigninButtonEnabled(enabled: enabled)
    }
    
    // MARK: - Account
    private func signin(username username: String, password: String) {
        let account = Account.account(username: username, password: password)
        
        if AccountDataBase.accountAuthenticated(account: account) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let welcomeViewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardID.welcomeViewController) as! WelcomeViewController
            welcomeViewController.username = account.username
            let navigationController = UINavigationController(rootViewController: welcomeViewController)
            presentViewController(navigationController, animated: true, completion: nil)
        } else {
            loginFailedView.hidden = false
        }
    }
    
    private func signup(username username: String, password: String) {
        if AccountDataBase.accountExistent(username: username) {
            showReminderAlert(title: nil, message: "“\(username)” is already existent, please try another username")
            return
        }
        
        let account = Account.account(username: username, password: password)
        AccountDataBase.storeAccount(account, success: { Void in
            self.resetUI()
            self.showReminderAlert(title: nil, message: "Successfully signed up “\(username)”")
            }, failure: { Void in
                self.showReminderAlert(title: nil, message: "Failed to sign up “\(username)”")
        })
    }
}

