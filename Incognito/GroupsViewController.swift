//
//  GroupsViewController.swift
//  Incognito
//
//  Created by Matthew Olson on 6/14/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import ParseUI

class GroupsViewController: PFQueryTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messagesViewController : MessagesViewController!
    var imageView : UIImageView!
    
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
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerView = UIView(frame: CGRectMake(0, 0, 270, 270))
        
        let createGroupButton = UIButton(frame: CGRectMake(20, 225, 230, 40))
        createGroupButton.setTitle("Create Group", forState: UIControlState.Normal)
        createGroupButton.backgroundColor = UIColor.orangeColor()
        createGroupButton.addTarget(self, action: #selector(createGroup), forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(createGroupButton)
        
        let label = UILabel(frame: CGRectMake(0, 202, 270, 20))
        label.textAlignment = NSTextAlignment.Center
        label.text = PFUser.currentUser()!["name"] as? String
        headerView.addSubview(label)
        
        PFUser.currentUser()?.fetchInBackground()
        if (PFUser.currentUser()!["image"] != nil) {
            let userImage = PFUser.currentUser()!["image"] as! PFFile
            userImage.getDataInBackgroundWithBlock { (imageData, error) in
                if error == nil {
                    let image = UIImage(data:imageData!)
                    self.imageView = UIImageView(image: image)
                    self.imageView.frame = CGRect(x: 40, y: 10, width: 190, height: 190)
                    headerView.addSubview(self.imageView)
                
                    let button = UIButton(frame: CGRectMake(40, 10, 190, 190))
                    button.backgroundColor = UIColor.clearColor()
                    button.addTarget(self, action: #selector(self.changeImage), forControlEvents: UIControlEvents.TouchUpInside)
                    headerView.addSubview(button)
                }
            }
        } else {
            let image = UIImage(named: "DefaultUserLarge.png")
            self.imageView = UIImageView(image: image)
            self.imageView.frame = CGRect(x: 40, y: 10, width: 190, height: 190)
            headerView.addSubview(self.imageView)
            
            let button = UIButton(frame: CGRectMake(40, 10, 190, 190))
            button.backgroundColor = UIColor.clearColor()
            button.addTarget(self, action: #selector(self.changeImage), forControlEvents: UIControlEvents.TouchUpInside)
            headerView.addSubview(button)
        }
        
        self.tableView.tableHeaderView = headerView
        
    }

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Group")
        query.whereKey("members", containsString: PFUser.currentUser()?.username)
        query.orderByDescending("updated")
        
        return query
    }
    
    func changeImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let croppedImage = squareImage(pickedImage)
            self.imageView.image = croppedImage
            let imageData = UIImageJPEGRepresentation(croppedImage, 0.2)
            let imageFile:PFFile = PFFile(data: imageData!)!
            PFUser.currentUser()?.setObject(imageFile, forKey: "image")
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error saving image", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            });
        }
        dismissViewControllerAnimated(true, completion: nil)
        
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = String(self.objects![indexPath.row].objectForKey("name")!)
        return cell
    }
    
    func squareImage(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var edge: CGFloat = 0.0
        
        if (originalWidth > originalHeight) {
            // landscape
            edge = originalHeight
            x = (originalWidth - edge) / 2.0
            y = 0.0
            
        } else if (originalHeight > originalWidth) {
            // portrait
            edge = originalWidth
            x = 0.0
            y = (originalHeight - originalWidth) / 2.0
        } else {
            // square
            edge = originalWidth
        }
        
        let cropSquare = CGRectMake(x, y, edge, edge)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }

}
