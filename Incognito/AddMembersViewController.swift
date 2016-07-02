//
//  AddMembersViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/16/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import Parse
import Contacts

class AddMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView  =   UITableView()
    var contactStore = CNContactStore()
    var contacts: [String : [CNContact]] = [String : [CNContact]]()
    let keysToFetch = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
    var groupObject : PFObject!
    var groupMembers : [String] = []
    var viewController : UIViewController = UIViewController()
    var outboundNumbers = ""
    var sortedContacts: [(String, [CNContact])]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64))
        
        navigationBar.barTintColor = UIColor.orangeColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Add Contacts"
        
        let leftButton =  UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(goBack))
        leftButton.tintColor = UIColor.whiteColor()
        let rightButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(goDone))
        rightButton.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            let alert = UIAlertController(title: "Error getting contact list", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        var allContacts: [CNContact] = []
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                allContacts.appendContentsOf(containerResults)
            } catch {
                let alert = UIAlertController(title: "Error getting contact list", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        for contact in allContacts {
            for phoneNumber in contact.phoneNumbers {
                if phoneNumber.label == "_$!<Mobile>!$_" {
                    let number = phoneNumber.value as! CNPhoneNumber
                    let numberString = number.stringValue
                    var digits = numberString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                    if digits.characters.count == 10 {
                        digits = "1" + digits
                    }
                    
                    if !groupMembers.contains(digits) {
                        let name = contact.givenName
                        if name.characters.count > 0 {
                        if contacts[String(name[name.startIndex.advancedBy(0)])] == nil {
                            contacts[String(name[name.startIndex.advancedBy(0)])] = [contact];
                        } else {
                            contacts[String(name[name.startIndex.advancedBy(0)])]?.append(contact)
                        }
                        }
                    }
                }
            }
        }
        
        sortedContacts = contacts.sort{ $0.0 < $1.0 }
        
        tableView = UITableView(frame: CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-64), style: UITableViewStyle.Plain)
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
    
    }
    
    func setGroup(object: PFObject) {
        groupObject = object
        groupMembers = groupObject["members"] as! [String]
    }
    
    func setPreviousController(controller : UIViewController) {
        viewController = controller
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let (_, myContacts) = sortedContacts[section]
        return myContacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        let (_, myContacts) = sortedContacts[indexPath.section]
        cell.textLabel!.text = myContacts[indexPath.row].givenName + " " + myContacts[indexPath.row].familyName
        
        let label = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width-50, 0, 50, cell.bounds.height))
        label.textAlignment = NSTextAlignment.Center
        label.text = "Add"
        cell.contentView.addSubview(label)
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var (letter, myContacts) = sortedContacts[indexPath.section]
        let contact = myContacts.removeAtIndex(indexPath.row)
        sortedContacts[indexPath.section] = (letter,myContacts)
        for phoneNumber in contact.phoneNumbers {
            if phoneNumber.label == "_$!<Mobile>!$_" {
                let number = phoneNumber.value as! CNPhoneNumber
                let numberString = number.stringValue
                var digits = numberString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                if digits.characters.count == 10 {
                    digits = "1" + digits
                }
                groupMembers.append(digits)
                outboundNumbers = outboundNumbers + digits + "<"
            }
        }
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortedContacts.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (letter, _) = sortedContacts[section]
        return letter
    }
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goDone() {
        groupObject["members"] = groupMembers
        PFCloud.callFunctionInBackground("smsNewMembers", withParameters: ["phonenumber":outboundNumbers])
        groupObject.saveInBackground()
        self.dismissViewControllerAnimated(true, completion: nil)
        viewController.dismissViewControllerAnimated(false, completion: nil)
    }

}
