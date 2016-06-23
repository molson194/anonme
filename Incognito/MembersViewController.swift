//
//  MembersViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/14/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import Parse

class MembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groupObject : PFObject!
    var members : [String]!
    var tableView: UITableView  =   UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.cyanColor()
        tableView = UITableView(frame: CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-64), style: UITableViewStyle.Plain)
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func setObject (object : PFObject) {
        groupObject = object
        groupObject.fetchIfNeededInBackground()
        members = groupObject.objectForKey("members") as? [String]
        print(groupObject["name"])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if members != nil {
            return members.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        let query : PFQuery = PFUser.query()!
        query.whereKey("username", equalTo: members[indexPath.row])
        query.countObjectsInBackgroundWithBlock { (numObjects, error) in
            if numObjects == 1 {
                query.getFirstObjectInBackgroundWithBlock { (user, error) in
                    if error == nil {
                        cell.textLabel!.text = user?.objectForKey("name") as? String
                    }
                }
            } else {
                cell.textLabel!.text = self.members[indexPath.row] // TODO: should I display members that have not joined yet?-->I think it's the easiest way
            }
        }
        return cell;
    }
    
}
