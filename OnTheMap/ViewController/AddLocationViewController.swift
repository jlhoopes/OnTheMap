//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 4/3/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import Foundation
import UIKit

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteURLTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = TextFieldDelegate.sharedInstance
        websiteURLTextField.delegate = TextFieldDelegate.sharedInstance
    }
    
    @IBAction func performCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func performAddLocation(_ sender: Any) {
        if (locationTextField.text! == ""){
            performAlert("Must Enter a Location", alertString: "Location Not Found")
        } else if (websiteURLTextField.text! == ""){
            performAlert("Must Enter a Website")
        } else {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmLocationViewController") as! ConfirmLocationViewController
            vc.location = locationTextField.text!
            vc.mediaURL = websiteURLTextField.text!
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    
    // MARK: Handle Errors
    func performAlert(_ messageString: String, alertString: String = "") {
        performUIUpdatesOnMain {
            self.activityIndicator.stopAnimating()
            // Login fail
            let alert = UIAlertController(title: alertString, message: messageString, preferredStyle: UIAlertControllerStyle.alert),
            dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}
