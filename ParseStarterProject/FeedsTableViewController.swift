//
//  FeedsTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Xin Zou on 11/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedsTableViewController: UITableViewController {
    

    var users = [String : String]() // [userID : userName]
    var messages =  [String]()
    var userNames = [String]()
    var imgFiles =  [PFFile]()
    
    
    func setUpPostsForUser(Id: String) {
        let posts = PFQuery(className: "Posts")
        posts.whereKey("userId", equalTo: Id)
        posts.findObjectsInBackground(block: { (objs, err) in
            if let objs = objs {
                for getPost in objs {
                    self.messages.append(getPost["message"] as! String)
                    self.imgFiles.append(getPost["imgFile"] as! PFFile)
                    self.userNames.append(self.users[ getPost["userId"] as! String ]! )
                    
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        users.removeAll()
        
        let usersQuery = PFUser.query()
        usersQuery?.findObjectsInBackground(block: { (objects,error) in
            if error != nil {
                print("error in FeedsTableViewController.swift :: viewDidLoad(): \(error!)")
            }else{
                if let objects = objects {
                    
                    for getObj in objects { // should have only one user inside: current();
                        if let user = getObj as? PFUser {
                            self.users[user.objectId!] = user.username!
                        }
                    }
                    // now we got all user name and id in the map
                }
                
                let getFollowedUsersQuery = PFQuery(className: "Followers")
                // then find all ohter following for current user;
                getFollowedUsersQuery.whereKey("follower", equalTo: (PFUser.current()?.objectId)! )
                getFollowedUsersQuery.findObjectsInBackground(block: { (followerObjs, err) in
                    if let followers = followerObjs {
                        for getFollower in followers {
                            if let follower = getFollower as? PFObject {
                                let followedUser = follower["following"] as! String
                                
                                self.setUpPostsForUser(Id: followedUser)
                            }
                        }
                        // end of for;
                    }
                })
            } // end of else (error checking)
        })
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return imgFiles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedsTableViewCell
        
        imgFiles[indexPath.row].getDataInBackground(block: { (file, err) in
            if let imgData = file {
                if let downloadImg = UIImage(data: imgData) {
                    cell.feedImg.image = downloadImg
                }
            }
        })
        
        cell.feedImg.image = UIImage(named: "shakira03")
        cell.nameLabel.text = userNames[indexPath.row]
        cell.msgTextView.text = messages[indexPath.row]
        

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
