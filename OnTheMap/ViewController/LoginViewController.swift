//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/29/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import UIKit

    class LoginViewController: UIViewController {
        @IBOutlet weak var loginStackView: UIStackView!
        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var passwordTextField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        emailTextField.delegate = TextFieldDelegate.sharedInstance
        passwordTextField.delegate = TextFieldDelegate.sharedInstance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK Keyboard routines
    @objc func keyboardWillShow(_ notification:Notification) {
        if emailTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification) + 100
        }
        
        if passwordTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification) + 100
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

}

