//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Xin Zou on 11/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {

    var userNames = [""]
    var userIds = [""]
    var isFollowing = ["" : true] // recording whom do I following: [id:true]
    
    var refresher : UIRefreshControl!
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        performSegue(withIdentifier: "logOut", sender: self)
    }
    
    
    //------------------------------------------------------
    func refresh() {
        
        userNames.removeAll()
        userIds.removeAll()
        isFollowing.removeAll()
        
        let queue = PFUser.query()
        userNames.removeAll()
        
        queue?.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print("error: find objects in background err: \(error!)")
            }else
                if let getObjs = objects {
                    
                    for obj in getObjs {
                        if let getUser = obj as? PFUser {
                            if getUser.objectId! == PFUser.current()?.objectId {
                                continue // because you do not need to see yourself in table;
                            }
                            let nameArray = getUser.username!.components(separatedBy: "@") // get name instead email
                            self.userNames.append(nameArray[0])
                            self.userIds.append(getUser.objectId!)
                            
                            let followers = PFQuery(className: "Followers")
                            // find out who is my follower:
                            followers.whereKey("follower", equalTo: (PFUser.current()?.objectId)! )
                            // and whom do I following:
                            followers.whereKey("following", equalTo: getUser.objectId! )
                            
                            followers.findObjectsInBackground(block: { (objects, error) in
                                // records the following relationship, then set checkmark in table cells;
                                if let objs = objects {
                                    self.isFollowing[getUser.objectId!] = (objs.count > 0) // true,false
                                }
                                if self.userNames.count == self.isFollowing.count { // relow after we get all data;
                                    // self.tableView.reloadData()
                                    self.animatedTable() // defined at following;
                                    self.refresher.endRefreshing() // stop table refresh;
                                }
                            })
                            //
                        }
                    }
            }
        })
        // end of find objects in background;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(TableViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false // show navigation bar again.
        
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
        return userNames.count
    }


    // set up the table before it loaded:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = userNames[indexPath.row]

        if isFollowing[ userIds[indexPath.row] ]! {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    
    // when user selects one row at table:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let getCell = tableView.cellForRow(at: indexPath)
        
        if isFollowing[ userIds[indexPath.row] ]! { // find following record, then
            isFollowing[ userIds[indexPath.row] ] = false
            getCell?.accessoryType = .none // remove the check mark;
            
            // then remove the following relationship in parse: 
            let findFollowers = PFQuery(className: "Followers")
            findFollowers.whereKey("follower", equalTo: (PFUser.current()?.objectId)! )
            findFollowers.whereKey("following", equalTo: userIds[indexPath.row] )
            findFollowers.findObjectsInBackground(block: { (objects, error) in
                if let objects = objects {
                    for obj in objects {
                        obj.deleteInBackground() // unfollow one user, delete the record;
                    }
                }
            })
            
        }else{ // not follow yet, then add follower:
            
            isFollowing[ userIds[indexPath.row] ] = true
            getCell?.accessoryType = .checkmark
        
            let followers = PFObject(className: "Followers")
            followers["follower"] = PFUser.current()?.objectId // set self as follower
            followers["following"] = userIds[indexPath.row]    // records all my followings
        
            followers.saveInBackground()
        }
    }
    
    
    func animatedTable() {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        
        let tableViewHeight = tableView.bounds.size.height
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        
        var delayCount = 0
        for cell in cells {
            UIView.animate(withDuration: 1.75, delay: Double(delayCount) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { cell.transform = CGAffineTransform.identity }, completion: nil)
            delayCount += 1
        }
        
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
