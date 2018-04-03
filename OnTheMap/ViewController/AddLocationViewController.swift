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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func performCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
