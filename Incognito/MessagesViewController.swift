//
//  MessagesViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/13/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import Parse
import SlackTextViewController

class MessagesViewController: SLKTextViewController {
    
    init() {
        scroll = UITextView()
        refreshView = UIRefreshControl()
        scroll?.addSubview(refreshView)
        super.init(scrollView: scroll!)
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TOOD: view did reload reload pf object data
    var groupObject : PFObject!
    var membersViewController : MembersViewController!
    let navItem = UINavigationItem()
    var scroll: UITextView?
    var refreshView : UIRefreshControl
    var queryAmount = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.placeholder = "Message"
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64))
        
        navigationBar.barTintColor = UIColor.orangeColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        navItem.title = "No Groups :("
        
        let leftButton =  UIBarButtonItem(image: UIImage(named: "GroupIcon.png"), style: .Plain, target: self, action: #selector(viewGroups))
        leftButton.tintColor = UIColor.whiteColor()
        let rightButton = UIBarButtonItem(image: UIImage(named: "UserIcon.png"), style: .Plain, target: self, action: #selector(viewMembers))
        rightButton.tintColor = UIColor.whiteColor()
        navItem.leftBarButtonItem = leftButton
        navItem.rightBarButtonItem = rightButton
        
        navigationBar.items = [navItem]
        self.view.addSubview(navigationBar)
        
        self.inverted = false

        scroll?.scrollEnabled = true
        scroll?.text = "No messages to show :("
        scroll?.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        scroll?.setContentOffset(CGPointMake(0, self.scroll!.contentSize.height), animated: false)
        scroll?.editable = false
        scroll?.font = UIFont.systemFontOfSize(16)
        
        refreshView.addTarget(self, action: #selector(refresh), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func setMembersView (viewController : MembersViewController) {
        membersViewController = viewController
    }
    
    func setObject(object : PFObject) {
        groupObject = object
        navItem.title = groupObject.objectForKey("name") as? String
        membersViewController.setObject(groupObject)
        queryAmount = 50
        
        self.reloadText()
    }
    
    func refresh() {
        queryAmount = queryAmount + 20
        reloadText()
        refreshView.endRefreshing()
    }
    
    func reloadText() {
        self.scroll?.text = ""
        
        let query = PFQuery(className: "Message")
        query.limit = queryAmount
        query.whereKey("groupId", equalTo: groupObject.objectId!)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (messages, error) in
            if error == nil && messages?.count > 0 {
                for message in messages! {
                    self.scroll?.text = String(message.objectForKey("text")!) + " " + (self.scroll?.text)!
                }
                if self.queryAmount == 50 && self.scroll!.contentSize.height > (self.scroll?.frame.size.height)!{
                    self.scroll?.setContentOffset(CGPointMake(0, self.scroll!.contentSize.height-(self.scroll?.frame.size.height)!), animated: false)
                }
                if self.scroll!.contentSize.height < (self.scroll?.frame.size.height)! {
                    self.scroll?.contentSize = CGSizeMake((self.scroll?.frame.size.width)!, (self.scroll?.frame.size.height)!)
                }
            } else if (messages?.count == 0) {
                self.scroll?.text = "No messages to show :("
                if self.scroll!.contentSize.height < (self.scroll?.frame.size.height)! {
                    self.scroll?.contentSize = CGSizeMake((self.scroll?.frame.size.width)!, (self.scroll?.frame.size.height)!)
                }
            }
        }
    }
    
    func viewGroups () {
        self.slideMenuController()?.openLeft()
    }
    
    func viewMembers() {
        if (groupObject != nil) {
            self.slideMenuController()?.openRight()
        }
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        let message = PFObject(className:"Message")
        message["groupId"] = groupObject.objectId
        message["text"] = self.textView.text
        message.saveInBackgroundWithBlock { (success, error) in
            if error == nil {
                self.textView.slk_clearText(true)
                self.textView.resignFirstResponder()
                self.reloadText()
                
                self.groupObject["updated"] = NSDate()
                self.groupObject.saveInBackground()
            }
        }
    }
}
