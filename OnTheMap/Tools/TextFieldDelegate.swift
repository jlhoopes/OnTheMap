//
//  TextFieldDelegate.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/30/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import Foundation
import UIKit

class TextFieldDelegate : NSObject, UITextFieldDelegate {
    
    static let sharedInstance : TextFieldDelegate = TextFieldDelegate()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Return control
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
