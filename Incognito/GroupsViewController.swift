//
//  GroupsViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/14/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import ParseUI

class GroupsViewController: PFQueryTableViewController {
    
    var messagesViewController : MessagesViewController!
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        self.parseClassName = "Group"
        self.objectsPerPage = 10
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false

    }
    
    // TODO: add cells programatically
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 200))
        headerView.backgroundColor = UIColor.greenColor()
        
        let createGroupButton = UIButton(frame: CGRectMake(20, 150, UIScreen.mainScreen().bounds.width-90, 40)) // TODO: center
        createGroupButton.setTitle("Create Group", forState: UIControlState.Normal)
        createGroupButton.backgroundColor = UIColor.blueColor()
        createGroupButton.addTarget(self, action: #selector(createGroup), forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(createGroupButton)
        
        let label = UILabel(frame: CGRectMake(0, 100, UIScreen.mainScreen().bounds.width-90, 20)) // TODO: center
        label.textAlignment = NSTextAlignment.Center
        label.text = PFUser.currentUser()!["name"] as? String
        headerView.addSubview(label)
        
        self.tableView.tableHeaderView = headerView
        
        // if self.objects.count == 0, add a footer with "Don;t belong to any groups :(. Create a new greoup!!
        
    }

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Group")
        query.whereKey("members", containsString: PFUser.currentUser()?.username)
        query.orderByAscending("createdAt") // TODO: order by updated at
        
        return query
    }
    
    func createGroup () {
        let newGroupViewController : NewGroupViewController = NewGroupViewController()
        self.presentViewController(newGroupViewController, animated: true, completion: nil)
    }
    
    func setMessagesController(viewController : MessagesViewController) {
        messagesViewController = viewController
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        messagesViewController.setObject(self.objects![indexPath.row])
        self.slideMenuController()?.closeLeft()
        
    }

}
