//
//  MembersViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/14/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groupObject : PFObject!
    var members : [String]!
    var tableView: UITableView  =   UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, 270, 64))
        navigationBar.barTintColor = UIColor.orangeColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let navigationItem = UINavigationItem()
        navigationItem.title = "Members"
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        let headerView = UIView(frame: CGRectMake(0, 0, 270, 60))
        
        let addMembersButton = UIButton(frame: CGRectMake(20, 10, 230, 40))
        addMembersButton.setTitle("Add Members", forState: UIControlState.Normal)
        addMembersButton.backgroundColor = UIColor.orangeColor()
        addMembersButton.addTarget(self, action: #selector(addMembers), forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(addMembersButton)
        
        tableView = UITableView(frame: CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-64), style: UITableViewStyle.Plain)
        tableView.tableHeaderView = headerView
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if groupObject != nil {
            members = groupObject.objectForKey("members") as? [String]
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if members != nil {
            if members != (groupObject.objectForKey("members") as? [String])! {
                groupObject["members"] = members
                groupObject.saveInBackground()
            }
        }
    }
    
    func setObject (object : PFObject) {
        groupObject = object
        groupObject.fetchIfNeededInBackground()
    }
    
    func addMembers() {
        let addMembersViewController : AddMembersViewController = AddMembersViewController()
        addMembersViewController.setGroup(groupObject)
        self.presentViewController(addMembersViewController, animated: true, completion: nil)
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
                        user?.fetchInBackground()
                        cell.textLabel!.text = user?.objectForKey("name") as? String
                        if ((user?.objectForKey("image")) != nil) {
                            let userImage = user?.objectForKey("image") as! PFFile
                            do {
                                let imageData = try userImage.getData()
                                let image = UIImage(data:imageData)!
                                cell.imageView?.image = image
                            } catch {
                                print("Doesn't work")
                            }
                        } else {
                            let image : UIImage = UIImage(named: "DefaultUser.png")!
                            cell.imageView!.image = image
                        }
                        
                    }
                }
            } else {
                cell.textLabel!.text = self.members[indexPath.row]
                let image : UIImage = UIImage(named: "DefaultCell.png")!
                cell.imageView!.image = image
            }
        }

        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let alert = UIAlertController(title: "Remove User", message: "Do you really want to remove " + (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)! + "?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action) in
            self.members.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
