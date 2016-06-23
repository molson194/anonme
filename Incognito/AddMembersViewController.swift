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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64))
        
        navigationBar.backgroundColor = UIColor.blueColor()
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Add Contacts"
        
        let leftButton =  UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(goBack)) // TODO: icon
        let rightButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(goDone)) // TODO: icon
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            // TODO: Display error (error getting contact list)
        }
        
        var allContacts: [CNContact] = []
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                allContacts.appendContentsOf(containerResults)
            } catch {
                // TODO: Display error (error getting contact list)
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
                        if contacts[String(name[name.startIndex.advancedBy(0)])] == nil {
                            contacts[String(name[name.startIndex.advancedBy(0)])] = [contact];
                        } else {
                        contacts[String(name[name.startIndex.advancedBy(0)])]?.append(contact)
                        }
                    }
                }
            }
        }
        
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
        let index = contacts.startIndex.advancedBy(section)
        return contacts[contacts.keys[index]]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let section = contacts.startIndex.advancedBy(indexPath.section)
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        cell.textLabel!.text = contacts[contacts.keys[section]]![indexPath.row].givenName + " " + contacts[contacts.keys[section]]![indexPath.row].familyName
        
        let label = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width-50, 0, 50, cell.bounds.height))
        label.textAlignment = NSTextAlignment.Center
        label.text = "Add"
        cell.contentView.addSubview(label)
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let section = contacts.startIndex.advancedBy(indexPath.section)
        let contact = contacts[contacts.keys[section]]?.removeAtIndex(indexPath.row)
        for phoneNumber in contact!.phoneNumbers {
            if phoneNumber.label == "_$!<Mobile>!$_" {
                let number = phoneNumber.value as! CNPhoneNumber
                let numberString = number.stringValue
                var digits = numberString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                if digits.characters.count == 10 {
                    digits = "1" + digits
                }
                groupMembers.append(digits)
            }
        }
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let index = contacts.startIndex.advancedBy(section)
        return contacts.keys[index]
    }
    
    func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goDone() {
        groupObject["members"] = groupMembers
        // TODO: send text message to all groupMembers that they've been added to group
        groupObject.saveInBackground()
        self.dismissViewControllerAnimated(true, completion: nil)
        viewController.dismissViewControllerAnimated(false, completion: nil) // TODO: Instead push home view controller?
    }

}
