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
    
    private struct AppInfo {
        static let urlString = "app://OnePasswordExample"
        static let title = "OnePasswordExample"
    }
    
    // MARK: - Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var onePasswordButton: UIButton!
    @IBOutlet weak var loginFailedView: UIView!
    
    @IBOutlet weak var signupAdditionalView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var additionalViewHeight: NSLayoutConstraint!
    
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
        resetUI()
        updateUI()
        
        usernameTextField.enablesReturnKeyAutomatically = true
        passwordTextField.enablesReturnKeyAutomatically = true
        firstNameTextField.enablesReturnKeyAutomatically = true
        lastNameTextField.enablesReturnKeyAutomatically = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selectors.textFieldDidChange, name: UITextFieldTextDidChangeNotification, object: usernameTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selectors.textFieldDidChange, name: UITextFieldTextDidChangeNotification, object: passwordTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selectors.textFieldDidChange, name: UITextFieldTextDidChangeNotification, object: firstNameTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selectors.textFieldDidChange, name: UITextFieldTextDidChangeNotification, object: lastNameTextField)
    }
    
    private func updateUI() {
        if userInterfaceMode == .Signin {
            signinButton.setTitle("Sign in", forState: .Normal)
            reminderLabel.text = "Don't have an account?"
            signupButton.setTitle("Sign up", forState: .Normal)
            additionalViewHeight.constant = 0
        } else if userInterfaceMode == .Signup {
            signinButton.setTitle("Sign up", forState: .Normal)
            reminderLabel.text = "Already have an account?"
            signupButton.setTitle("Sign in", forState: .Normal)
            additionalViewHeight.constant = 85
        }
        
        resetUI()
        signupAdditionalView.hidden = userInterfaceMode == .Signin
        passwordTextField.secureTextEntry = userInterfaceMode == .Signin
        view.layoutIfNeeded()
    }
    
    private func resetUI() {
        hideKeyboard()
        usernameTextField.text = nil
        passwordTextField.text = nil
        firstNameTextField.text = nil
        lastNameTextField.text = nil
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
            signup(username: usernameTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!)
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
        } else {
            if userInterfaceMode == .Signin {
                loginFrom1Password(sender)
            } else if userInterfaceMode == .Signup {
                saveLoginTo1Password(sender)
            }
        }
    }
    
    @IBAction func didClickForgetPassword(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let accountsViewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardID.accountsViewController) as! AccountsViewController
        let navigationController = UINavigationController(rootViewController: accountsViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - 1Password
    private func loginFrom1Password(sender: UIButton) {
        OnePasswordExtension.sharedExtension().findLoginForURLString(AppInfo.urlString, forViewController: self, sender: sender, completion: { (loginDictionary, error) -> Void in
            if loginDictionary?.isEmpty == true {
                return
            }
            
            if let username = loginDictionary![AppExtensionUsernameKey] as? String {
                self.usernameTextField.text = username
                NSNotificationCenter.defaultCenter().postNotificationName(UITextFieldTextDidChangeNotification, object: self.usernameTextField)
            }
            if let password = loginDictionary![AppExtensionPasswordKey] as? String {
                self.passwordTextField.text = password
                NSNotificationCenter.defaultCenter().postNotificationName(UITextFieldTextDidChangeNotification, object: self.passwordTextField)
            }
            
        })
    }
    
    private func saveLoginTo1Password(sender: UIButton) {
        
    }
    
    // MARK: - Account
    private func signin(username username: String, password: String) {
        let account = Account.account(username: username, password: password, firstName: nil, lastName: nil)
        
        if AccountDataBase.accountAuthenticated(account: account).authenticated {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let welcomeViewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardID.welcomeViewController) as! WelcomeViewController
            welcomeViewController.loginAccount = AccountDataBase.accountAuthenticated(account: account).account!
            let navigationController = UINavigationController(rootViewController: welcomeViewController)
            presentViewController(navigationController, animated: true, completion: nil)
        } else {
            loginFailedView.hidden = false
        }
    }
    
    private func signup(username username: String, password: String, firstName: String, lastName: String) {
        if AccountDataBase.accountExistent(username: username) {
            showReminderAlert(title: nil, message: "“\(username)” is already existent, please try another username")
            return
        }
        
        let account = Account.account(username: username, password: password, firstName: firstName, lastName: lastName)
        AccountDataBase.storeAccount(account, success: { Void in
            self.resetUI()
            self.showReminderAlert(title: "Congratulation!", message: "\(firstName) \(lastName), successfully signed up “\(username)”.")
            }, failure: { Void in
                self.showReminderAlert(title: "Sorry!", message: "\(firstName) \(lastName), fail to sign up “\(username)”.")
        })
    }
    
    // MARK: - TextField observer
    func accountTextFieldDidChange(notification: NSNotification) {
        loginFailedView.hidden = true
        
        var enabled = usernameTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
        if userInterfaceMode == .Signup {
            enabled = enabled && firstNameTextField.text?.isEmpty == false && lastNameTextField.text?.isEmpty == false
        }
        
        setSigninButtonEnabled(enabled: enabled)
    }
}

