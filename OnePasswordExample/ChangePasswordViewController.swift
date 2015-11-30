//
//  ChangePasswordViewController.swift
//  OnePasswordExample
//
//  Created by 洪鑫 on 15/11/30.
//  Copyright © 2015年 Xin Hong. All rights reserved.
//

import UIKit
import OnePasswordExtension

class ChangePasswordViewController: UIViewController {
    // MARK: - Structs
    private struct Selectors {
        static let resignFirstResponder: Selector = "resignFirstResponder"
        static let textFieldDidChange: Selector = "passwordTextFieldDidChange:"
    }
    
    // MARK: - Properties
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var loginAccount: Account!
    var oldPasswordFor1Password: String?
    
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
        if let firstName = loginAccount.firstName, lastName = loginAccount.lastName {
            navigationItem.title = firstName + " " + lastName
        }
        
        reminderLabel.text = "Set a new password for account “\(loginAccount.username!)”:"
        reminderLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        passwordTextField.enablesReturnKeyAutomatically = true
        setSaveButtonEnabled(enabled: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selectors.textFieldDidChange, name: UITextFieldTextDidChangeNotification, object: passwordTextField)
    }
    
    private func hideKeyboard() {
        UIApplication.sharedApplication().sendAction(Selectors.resignFirstResponder, to: nil, from: nil, forEvent: nil)
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
    
    private func setSaveButtonEnabled(enabled enabled: Bool) {
        saveButton.enabled = enabled
        if saveButton.enabled {
            saveButton.backgroundColor = Colors.buttonEnabledColor
        } else {
            saveButton.backgroundColor = Colors.buttonDisabledColor
        }
    }
    
    // MARK: - Selectors
    @IBAction func didClickSaveButton(sender: UIButton) {
        hideKeyboard()
        
        loginAccount.password = passwordTextField.text
        AccountDataBase.updateAccount(username: loginAccount.username!, newAccount: loginAccount, success: { Void in
                self.showReminderAlert(title: nil, message: "Successfully changed password!")
            }, failure: { Void in
                self.showReminderAlert(title: nil, message: "Failed to change password!")
        })
    }
    
    @IBAction func didClick1PasswordIcon(sender: UIButton) {
        hideKeyboard()
        
        if !OnePasswordExtension.sharedExtension().isAppExtensionAvailable() {
            show1PasswordUnavailableAlert()
            return
        } else {
            if passwordTextField.text!.isEmpty == true {
                showReminderAlert(title: nil, message: "New password is required!")
                return
            }
            
            if oldPasswordFor1Password == nil {
                oldPasswordFor1Password = loginAccount.password
            }
            
            changePasswordIn1Password(sender)
        }
    }
    
    @IBAction func touchDownBackgroundView(sender: UIControl) {
        hideKeyboard()
    }
    
    @IBAction func touchDownContentView(sender: UIControl) {
        hideKeyboard()
    }
    
    // MARK: - 1Password
    private func changePasswordIn1Password(sender: UIButton) {
        let loginDetails: [String: AnyObject] = [AppExtensionTitleKey: AppInfo.title,
            AppExtensionUsernameKey: loginAccount.username!,
            AppExtensionPasswordKey: passwordTextField.text!,
            AppExtensionOldPasswordKey: oldPasswordFor1Password!,
            AppExtensionNotesKey: "Saved by OnePasswordExtension",]
        
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
        
        OnePasswordExtension.sharedExtension().changePasswordForLoginForURLString(AppInfo.urlString, loginDetails: loginDetails, passwordGenerationOptions: passwordGenerationOptions, forViewController: self, sender: sender) { (loginDictionary, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let loginDictionary = loginDictionary {
                if loginDictionary.isEmpty == true {
                    return
                }
                print("Account has been updated: \r\(loginDictionary)")
            }
        }
    }
    
    // MARK: - TextField observer
    func passwordTextFieldDidChange(notification: NSNotification) {
        let enabled = passwordTextField.text?.isEmpty == false
        
        setSaveButtonEnabled(enabled: enabled)
    }
}
