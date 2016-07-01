//
//  VerificationViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/13/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import Parse
import SlideMenuControllerSwift

class VerificationViewController: UIViewController {
    
    let label = UILabel(frame: CGRectMake(0, 40, UIScreen.mainScreen().bounds.width, 40))
    let verificationField = UITextField(frame: CGRectMake(20, 80, UIScreen.mainScreen().bounds.width-40, 40))
    let verifyButton = UIButton(frame: CGRectMake(20, 120, UIScreen.mainScreen().bounds.width-40, 40))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        label.textAlignment = NSTextAlignment.Center
        label.text = "Wait for SMS verification code"
        self.view.addSubview(label)
        
        verificationField.keyboardType = UIKeyboardType.NumberPad
        verificationField.borderStyle = UITextBorderStyle.RoundedRect
        self.verificationField.placeholder = "Verification Code"
        self.view.addSubview(verificationField)
        
        verifyButton.setTitle("Sign Up", forState: UIControlState.Normal)
        verifyButton.backgroundColor = UIColor.blueColor()
        verifyButton.addTarget(self, action: #selector(verifyPressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(verifyButton)
        
    }
    
    func verifyPressed(){
        let user = PFUser.currentUser()
        if String(user!["random"]) == verificationField.text {
            user!["isVerified"] = true
            user?.saveInBackground()
            
            let groupsViewController = GroupsViewController()
            let messagesViewController = MessagesViewController()
            let query = PFQuery(className: "Group")
            query.whereKey("members", containsString: user!.username)
            query.orderByDescending("updated")
            query.getFirstObjectInBackgroundWithBlock({ (object, error) in
                if error == nil {
                    messagesViewController.setObject(object!)
                }
            })
            let membersViewController = MembersViewController()
            groupsViewController.setMessagesController(messagesViewController)
            messagesViewController.setMembersView(membersViewController)
            let slideMenuController = SlideMenuController(mainViewController: messagesViewController, leftMenuViewController: groupsViewController, rightMenuViewController: membersViewController)
            
            self.presentViewController(slideMenuController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Verification code does not match", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
