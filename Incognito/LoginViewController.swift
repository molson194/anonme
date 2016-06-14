//
//  LoginViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/8/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import PhoneNumberKit
import Parse

class LoginViewController: UIViewController {
    
    let nameField = UITextField(frame: CGRectMake(20, 100, UIScreen.mainScreen().bounds.width-40, 40))
    let phoneField = PhoneNumberTextField()
    let passwordField = UITextField(frame: CGRectMake(20, 180, UIScreen.mainScreen().bounds.width-40, 40))
    let signUpButton = UIButton(frame: CGRectMake(20, 220, UIScreen.mainScreen().bounds.width-40, 40))
    let signInButton = UIButton(frame: CGRectMake(20, 220, UIScreen.mainScreen().bounds.width-40, 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let options = ["Sign Up", "Sign In"]
        let sc = UISegmentedControl(items: options)
        sc.frame = CGRectMake(20, 20, UIScreen.mainScreen().bounds.width-40, 40)
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(changedSC), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(sc)
        
        // TODO: Logo at top
        
        nameField.placeholder = "Full Name"
        nameField.borderStyle = UITextBorderStyle.RoundedRect
        nameField.autocorrectionType = UITextAutocorrectionType.No
        self.view.addSubview(nameField)
        
        phoneField.frame = CGRectMake(20, 140, UIScreen.mainScreen().bounds.width-40, 40)
        phoneField.placeholder = "Mobile Number"
        phoneField.borderStyle = UITextBorderStyle.RoundedRect
        self.view.addSubview(phoneField)
        
        passwordField.placeholder = "Password"
        passwordField.borderStyle = UITextBorderStyle.RoundedRect
        passwordField.secureTextEntry = true
        self.view.addSubview(passwordField)
        
        signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
        signUpButton.backgroundColor = UIColor.blueColor()
        signUpButton.addTarget(self, action: #selector(signUpPressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(signUpButton)
        
        signInButton.setTitle("Sign In", forState: UIControlState.Normal)
        signInButton.backgroundColor = UIColor.blueColor()
        signInButton.addTarget(self, action: #selector(signInPressed), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func signUpPressed(){
        
        if phoneField.isValidNumber && phoneField.currentRegion == "US"{
            var phoneNumber = phoneField.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
            
            if phoneNumber.characters.count == 10 {
                phoneNumber = "1" + phoneNumber
            }
            
            let random = arc4random_uniform(899999) + 100000;
            print(random)
            
            // TODO: check to see if user already exists
            
            let user = PFUser()
            user.username = phoneNumber
            user.password = passwordField.text
            user["name"] = nameField.text
            user["random"] = Double(random)
            user["isVerfied"] = false
            // TODO: random photo as cover
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    print(error.userInfo["error"] as? NSString)
                    // TODO: display error (Problem signing up)
                } else {
                    PFCloud.callFunctionInBackground("smsLoginVerification", withParameters: ["phonenumber":phoneNumber, "messagebody":"Verification Code: " + String(random)])
                    let verificationViewController : VerificationViewController = VerificationViewController()
                    self.presentViewController(verificationViewController, animated: true, completion: nil)
                }
            }

        } else {
            // TODO: display error (Must enter valid US number)
        }
    }
    
    func signInPressed () {
        if phoneField.isValidNumber && phoneField.currentRegion == "US"{
            var phoneNumber = phoneField.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
            
            if phoneNumber.characters.count == 10 {
                phoneNumber = "1" + phoneNumber
            }
            
            PFUser.logInWithUsernameInBackground(phoneNumber, password:passwordField.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    let messagesViewController : MessagesViewController = MessagesViewController()
                    self.presentViewController(messagesViewController, animated: true, completion: nil)
                } else {
                    // TODO: display error (issue logging in)
                }
            }
            
        }
    }
    
    func changedSC(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.view.addSubview(nameField)
            self.view.addSubview(signUpButton)
            signInButton.removeFromSuperview()
        } else {
            nameField.removeFromSuperview()
            signUpButton.removeFromSuperview()
            self.view.addSubview(signInButton)
        }
        
    }
    
}
