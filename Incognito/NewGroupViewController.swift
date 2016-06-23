//
//  NewGroupViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/14/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import Parse

class NewGroupViewController: UIViewController {
    
    let groupName = UITextField(frame: CGRectMake(20, 80, UIScreen.mainScreen().bounds.width-40, 40))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64))
        
        navigationBar.backgroundColor = UIColor.blueColor()
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "New Group"
        
        let leftButton =  UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(goBack)) // TODO: icon
        let rightButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(goNext)) // TODO: icon
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        groupName.borderStyle = UITextBorderStyle.RoundedRect
        self.groupName.placeholder = "Name your group..."
        self.view.addSubview(groupName)
        
    }
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goNext() {
        if (groupName.text?.characters.count > 0) {
            let group = PFObject(className:"Group")
            group["name"] = groupName.text
            group["members"] = [(PFUser.currentUser()?.username)!]
            let addMembersViewController : AddMembersViewController = AddMembersViewController()
            addMembersViewController.setGroup(group)
            addMembersViewController.setPreviousController(self)
            self.presentViewController(addMembersViewController, animated: true, completion: nil)
        } else {
            // TODO: display error (must have a group name
        }
    }
    
}
