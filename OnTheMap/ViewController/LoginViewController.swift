//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/29/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // FB Login check issue logout
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        
        
        let fbLoginButton = FBSDKLoginButton()
        
        loginStackView.addArrangedSubview(fbLoginButton)
        emailTextField.delegate = TextFieldDelegate.sharedInstance
        passwordTextField.delegate = TextFieldDelegate.sharedInstance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK User Info
    private func getCurrentUserInfo() {
        
        ParseClient.sharedInstance().getStudentInfo(completionHandlerLocation: {(studentInfo, error) in
            
            if (error != nil) {
                self.performAlert("Failed to get user")
            }
        })
    }
    // MARK Login
    @IBAction func performLogin(_ sender: Any) {
        activityIndicator.startAnimating()
        if (emailTextField.text! == "" || passwordTextField.text! == "") {
            performAlert("Empty Email or Password")
            activityIndicator.stopAnimating()
            return
        }
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        UdacityClient.sharedInstance().performUdacityLogin(email, password, completionHandlerLogin: { (error) in
            
            if let error = error {
                self.performAlert(error.localizedDescription)
            }
            else {
                self.getCurrentUserInfo()
                self.completeLogin()
                
            }
        })
    }
    // MARK Facebook Login
    func performFBLogin(_ fbToken: String) {
        UdacityClient.sharedInstance().performFacebookLogin(fbToken, completionHandlerFBLogin: { (error) in
            
            if (error == nil) {
                // Get User Info
                self.getCurrentUserInfo()
                // Complete Login
                self.completeLogin()
            }
            else {
                self.performAlert("Invalid Login, please try again.")
            }
        })
    }

    // MARK complete login
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.activityIndicator.startAnimating()
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "PrimaryNavigationController") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        }
    }
    // MARK Signup functions
    @IBAction func performSignup(_ sender: Any) {
        let signup = UIApplication.shared
        signup.open(URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!, options: [:])
    }
    /*
    // MARK Keyboard routines
    @objc func keyboardWillShow(_ notification:Notification) {
        if emailTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification) + 225
        }
        
        if passwordTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification) + 225
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if emailTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
        if passwordTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
 */
    //MARK Handle Errors
    func performAlert(_ messageString: String) {
        performUIUpdatesOnMain {
            self.activityIndicator.stopAnimating()
            // Login fail
            let alert = UIAlertController(title: nil, message: messageString, preferredStyle: UIAlertControllerStyle.alert),
                dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
            
        }
    }

}

//MARK Facebook Login Button
extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            performAlert("Facebook login failed")
            return
        }
        
        self.performFBLogin(result.token.tokenString)
    }
}

