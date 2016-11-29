//
//  PostViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Xin Zou on 11/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    var visualEffect : UIVisualEffect!
    
    @IBOutlet var alertView: UIView!
    
    @IBOutlet weak var alertText: UILabel!
    
    @IBAction func alertButtonTapped(_ sender: UIButton) {
        alertViewAnimateOut()
    }
    
    
    @IBOutlet weak var imageToPost: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func selectImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func alertViewAnimateIn(txt: String) {
        alertText.text = txt
        self.view.addSubview(alertView)
        alertView.center = self.view.center
        
        alertView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        alertView.alpha = 0
        
        visualEffectView.center = self.view.center // move visualEffect; 
        
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEffectView.effect = self.visualEffect
            self.alertView.transform = CGAffineTransform.identity
            self.alertView.alpha = 1
        })
    }
    func alertViewAnimateOut() {
        UIView.animate(withDuration: 0.5, animations: {
            // self.visualEffectView.effect = nil
            self.alertView.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            self.alertView.alpha = 0
        }, completion: {(Bool) in
            self.alertView.removeFromSuperview()
            self.visualEffectView.center = self.view.center + CGPoint(x: self.visualEffectView.frame.width, y: 0)
        })
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let getImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageToPost.image = getImg
        }
        self.dismiss(animated: true, completion: nil)
        // then goto Info.plist to modify privacy: Privacy - Photo Library Usage Description
    }
    
    
    @IBAction func postImage(_ sender: UIButton) {
        let post = PFObject(className: "Posts")
        post["message"] = textField.text
        post["userId"] = PFUser.current()?.objectId
        
        let imgData = UIImagePNGRepresentation(imageToPost.image!)
        let imgFile = PFFile(name: "post.png", data: imgData!)
        post["imgFile"] = imgFile
        
        post.saveInBackground(block: { (success,error) in
            if error != nil {
                let errtxt = "Fail to post image: \(error!)"
                self.alertViewAnimateIn(txt: errtxt)
            }else{
                self.alertViewAnimateIn(txt: "Great! Your photo had been post successfully!")
                self.textField.text  = ""
            }
        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        visualEffectView.center = self.view.center + CGPoint(x: visualEffectView.frame.width, y: 0)
        visualEffect = visualEffectView.effect
        alertView.layer.cornerRadius = 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
