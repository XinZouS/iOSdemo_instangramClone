/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    var loginModeOn = true
    let modeTextToSignUp = "New friend? SignUp here"
    let modeTextToLogin  = "Have account? Login here"
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    var visualEffect : UIVisualEffect!
    
    @IBOutlet var alertView: UIView!
    
    @IBOutlet weak var alertLabel: UILabel!
    let alertLabelText = "Please input your username and password."
    
    func alertViewAnimateIn(txt: String) {
        alertLabel.text = txt
        self.view.addSubview(alertView)
        alertView.center = self.view.center
        
        alertView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        alertView.alpha = 0
        
        blurEffect.center = self.view.center // move viewEffect in.
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blurEffect.effect = self.visualEffect
            self.alertView.transform = CGAffineTransform.identity // change back
            self.alertView.alpha = 1 // and show it
        })
    }
    
    func alertViewAnimateOut() {
        UIView.animate(withDuration: 0.5, animations: {
            self.blurEffect.effect = nil
            self.alertView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alertView.alpha = 0 // hide it
        }, completion: {(Bool) in
            self.alertView.removeFromSuperview()
            self.blurEffect.center = self.view.center + CGPoint(x: self.blurEffect.frame.width, y: 0)
        })
    }
    
    
    
    @IBAction func alertViewButtonTapped(_ sender: UIButton) {
        alertViewAnimateOut()
    }
    
    @IBOutlet weak var usernameTextField: ShakeTextField!
    
    @IBOutlet weak var passwordTextField: ShakeTextField!
    
    @IBOutlet weak var loginOrSignUpBtn: UIButton!
    
    @IBOutlet weak var switchModeBtn: UIButton!
    
    
    @IBAction func loginOrSignUp(_ sender: UIButton) {
        
        if usernameTextField.text == "" || passwordTextField.text == "" {
            alertViewAnimateIn(txt: alertLabelText)

        }else{
        
            self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:60, height:60))
            self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.center = self.view.center + CGPoint(x: 0, y: -30)
            self.activityIndicator.startAnimating()
            view.addSubview(activityIndicator)
            
            UIApplication.shared.beginIgnoringInteractionEvents() // ----------------------
            
            if loginModeOn { // parse server login:
                PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents() // ----------------------
                    
                    if error != nil {
                        self.alertViewAnimateIn(txt: "Login Failed: \(error!)")
                    }else{
                        
                    }
                })
                
            }else{ // parse server signUp:
                
                let user = PFUser()
                user.username = usernameTextField.text
                user.email = usernameTextField.text
                user.password = passwordTextField.text
                
                user.signUpInBackground(block: { (success, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents() // ----------------------
                    
                    if error != nil {
                        // if let errMsg = error.userInfo["error"] as? String { // this didnt work...
                        let errMsg = "Sign up Error: \(error!)"
                            self.alertViewAnimateIn(txt: errMsg)
                        // }
                    }else{ //sign up success, set local user and go to next page
                        //......
                    }
                })
            }
        }
        
        // animation bounse when tapped:
        let thisBtn = sender // as! UIButton
        let bounce = thisBtn.bounds // save its original bounce
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: .curveEaseInOut, animations: {
                thisBtn.bounds = CGRect(x: bounce.origin.x - 20, y: bounce.origin.y, width: bounce.size.width + 20, height: bounce.size.height - 6)
        }, completion: { (success:Bool) in
            if success {
                UIView.animate(withDuration: 0.5, animations: { thisBtn.bounds = bounce })
            }
        })
        /*
        // animation shake textField if get error: 
        usernameTextField.shake(duration: 0.05, repeatCount: 6)
        passwordTextField.shake(duration: 0.05, repeatCount: 6)
        */
        
        
    }
    
    @IBAction func switchMode(_ sender: UIButton) {
        if loginModeOn {
            loginModeOn = false
            loginOrSignUpBtn.setTitle("Sign Up", for: .normal)
            switchModeBtn.setTitle(modeTextToLogin, for: .normal)
        }else{
            loginModeOn = true
            loginOrSignUpBtn.setTitle("Login", for: .normal)
            switchModeBtn.setTitle(modeTextToSignUp, for: .normal)
        }
        print("now login mode is \(loginModeOn)")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /* ====================================================================== 
        // put new class(table) into db:------------------------
        let me = PFObject(className: "TinderUser")
        me["name"] = "SanKing"
        me.saveInBackground(block: { (success, error) in
            if success {
                print("saving success: \(success)")
            }else if error != nil {
                print("get err when saving: \(error)")
            }
        })
        // get object from class in db:-------------------------
        let queueOfObjs = PFQuery(className: "TinderUser")
        queueOfObjs.getObjectInBackground(withId: "zKCoEaUJJ9") { (object, err) in
            if let getObj = object {
                print("username: \(getObj["name"])")
                print(getObj)
            }else if err != nil {
                print("getting error: \(err)")
            }
        }
        */
        
        // for shaking textField: 
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        
        // for alert and blur effect
        self.visualEffect = blurEffect.effect!
        blurEffect.effect = nil
        alertView.layer.cornerRadius = 7
        
        blurEffect.center = self.view.center + CGPoint(x: blurEffect.frame.width, y: 0)
        
        print("Finish setting up in viewDidLoad().")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
