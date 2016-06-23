//
//  MessagesViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/13/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import Parse

class MessagesViewController: UIViewController {
    
    // TOOD: view did reload reload pf object data
    var groupObject : PFObject!
    var membersViewController : MembersViewController!
    let navItem = UINavigationItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64))
        
        navigationBar.backgroundColor = UIColor.blueColor()
        
        navItem.title = "No Groups :("
        
        let leftButton =  UIBarButtonItem(title: "Groups", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(viewGroups)) // TODO: icon
        let rightButton = UIBarButtonItem(title: "Members", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(viewMembers)) // TODO: icon
        navItem.leftBarButtonItem = leftButton
        navItem.rightBarButtonItem = rightButton
        
        navigationBar.items = [navItem]
        self.view.addSubview(navigationBar)
    
    }
    
    func setMembersView (viewController : MembersViewController) {
        membersViewController = viewController
    }
    
    func setObject(object : PFObject) {
        groupObject = object
        navItem.title = groupObject.objectForKey("name") as? String
    }
    
    func viewGroups () {
        self.slideMenuController()?.openLeft()
    }
    
    func viewMembers() {
        if (groupObject != nil) {
            membersViewController.setObject(groupObject)
            self.slideMenuController()?.openRight()
        }
    }
    
}
