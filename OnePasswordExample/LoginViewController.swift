//
//  LoginViewController.swift
//  OnePasswordExample
//
//  Created by 洪鑫 on 15/11/27.
//  Copyright © 2015年 Xin Hong. All rights reserved.
//

import UIKit
import OnePasswordExtension

struct AppInfo {
    static let urlString = "app://OnePasswordExample"
    static let title = "OnePasswordExample"
}

struct Colors {
    static let buttonEnabledColor = UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1)
    static let buttonDisabledColor = UIColor(white: 190 / 255, alpha: 1)
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
        static let textFieldDidChange: Selector = "accountTextFieldDidChange:"
    }
    
    private struct StoryboardID {
        static let accountsViewController = "AccountsViewController"
        static let welcomeViewController = "WelcomeViewController"
    }
    
    private struct Screen {
        static let height: CGFloat = UIScreen.mainScreen().bounds.height
        static let iPhone6PlusWidth: CGFloat = 736
        static let iPhone6Width: CGFloat = 667
        static let iPhone5Width: CGFloat = 568
        static let iPhone4Width: CGFloat = 480
    }
    
    private struct TopSpace {
        static let defaultTop: CGFloat = 80
        static let iPhone6PlusTop: CGFloat = 130
        static let iPhone6Top: CGFloat = 80
        static let iPhone5Top: CGFloat = 20
        static let iPhone4Top: CGFloat = 0
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
    
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if Screen.height == Screen.iPhone6PlusWidth {
            topSpace.constant = TopSpace.iPhone6PlusTop
        } else if Screen.height == Screen.iPhone6Width {
            topSpace.constant = TopSpace.iPhone6Top
        } else if Screen.height == Screen.iPhone5Width {
            topSpace.constant = TopSpace.iPhone5Top
        } else if Screen.height == Screen.iPhone4Width {
            topSpace.constant = TopSpace.iPhone4Top
        } else {
             topSpace.constant = TopSpace.defaultTop
        }
        
        view.layoutIfNeeded()
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
            additionalViewHeight.constant = 3
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
    
    private func showSignupSuccessAlert(account account: Account) {
        let alert = UIAlertController(title: "Congratulation!", message: "\(account.firstName!) \(account.lastName!), successfully signed up “\(account.username!)”.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let loginAction = UIAlertAction(title: "Login", style: .Default) { (action) -> Void in
            self.userInterfaceMode = .Signin
            self.usernameTextField.text = account.username
            self.passwordTextField.becomeFirstResponder()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(loginAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func hideKeyboard() {
        UIApplication.sharedApplication().sendAction(Selectors.resignFirstResponder, to: nil, from: nil, forEvent: nil)
    }

    // MARK: - Selector
    @IBAction func didClickSigninButton(sender: UIButton) {
        hideKeyboard()
        
        if userInterfaceMode == .Signin {
            signin(username: usernameTextField.text!, password: passwordTextField.text!)
        } else if userInterfaceMode == .Signup {
            signup(username: usernameTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!)
        }
    }

    @IBAction func didClickSignupButton(sender: UIButton) {
        hideKeyboard()
        
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
        hideKeyboard()
        
        if !OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
            show1PasswordUnavailableAlert()
            return
        } else {
            if userInterfaceMode == .Signin {
                loginFrom1Password(sender)
            } else if userInterfaceMode == .Signup {
                let account = Account.account(username: usernameTextField.text, password: passwordTextField.text, firstName: firstNameTextField.text, lastName: lastNameTextField.text)
                if !account.isValid() {
                    showReminderAlert(title: "Invalid Account", message: "first name, last name, username and password are all required!")
                    return
                }
                
                saveLoginTo1Password(sender)
            }
        }
    }
    
    @IBAction func didClickForgetPassword(sender: UIButton) {
        hideKeyboard()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let accountsViewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardID.accountsViewController) as! AccountsViewController
        let navigationController = UINavigationController(rootViewController: accountsViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - 1Password
    private func loginFrom1Password(sender: UIButton) {
        // About URLString,if 1Password doesn't find any matching password, 1Password will show all logins.
        OnePasswordExtension.sharedExtension().findLoginForURLString(AppInfo.urlString, forViewController: self, sender: sender, completion: { (loginDictionary, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let loginDictionary = loginDictionary {
                if loginDictionary.isEmpty == true {
                    return
                }
                
                if let username = loginDictionary[AppExtensionUsernameKey] as? String {
                    self.usernameTextField.text = username
                    NSNotificationCenter.defaultCenter().postNotificationName(UITextFieldTextDidChangeNotification, object: self.usernameTextField)
                }
                
                if let password = loginDictionary[AppExtensionPasswordKey] as? String {
                    self.passwordTextField.text = password
                    NSNotificationCenter.defaultCenter().postNotificationName(UITextFieldTextDidChangeNotification, object: self.passwordTextField)
                }
            }
        })
    }
    
    private func saveLoginTo1Password(sender: UIButton) {
        let loginDetails: [String: AnyObject] = [AppExtensionTitleKey: AppInfo.title,
            AppExtensionUsernameKey: usernameTextField.text!,
            AppExtensionPasswordKey: passwordTextField.text!,
            AppExtensionNotesKey: "Saved by OnePasswordExtension",
            AppExtensionSectionTitleKey: "OnePasswordExtension",
            AppExtensionFieldsKey: ["firstname": firstNameTextField.text!, "lastname": lastNameTextField.text!]]
        
        let passwordGenerationOptions = [
            // The minimum password length can be 4 or more.
            // AppExtensionGeneratedPasswordMinLengthKey: 8,
            
            // The maximum password length can be 50 or less.
            // AppExtensionGeneratedPasswordMaxLengthKey: 30,
            
            // If YES, the 1Password will guarantee that the generated password will contain at least one digit (number between 0 and 9). Passing NO will not exclude digits from the generated password.
            AppExtensionGeneratedPasswordRequireDigitsKey: false,
            
            // If YES, the 1Password will guarantee that the generated password will contain at least one symbol (See the list bellow). Passing NO with will exclude symbols from the generated password.
            AppExtensionGeneratedPasswordRequireSymbolsKey: false,
            
            // Here are all the symbols available in the the 1Password Password Generator:
            // !@#$%^&*()_-+=|[]{}'\";.,>?/~`
            // The string for AppExtensionGeneratedPasswordForbiddenCharactersKey should contain the symbols and characters that you wish 1Password to exclude from the generated password.
            // AppExtensionGeneratedPasswordForbiddenCharactersKey: "!@#$%/0lIO",
        ]
        
        OnePasswordExtension.sharedExtension().storeLoginForURLString(AppInfo.urlString, loginDetails: loginDetails, passwordGenerationOptions: passwordGenerationOptions, forViewController: self, sender: sender) { (loginDictionary, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let loginDictionary = loginDictionary {
                if loginDictionary.isEmpty == true {
                    return
                }
                print("Account has been stored: \r\(loginDictionary)")
            }
        }
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
                self.showSignupSuccessAlert(account: account)
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

