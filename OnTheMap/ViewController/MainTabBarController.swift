//
//  MainTabBarController.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 4/2/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func performLogout(_ sender: Any) {
        
        UdacityClient.sharedInstance().performUdacityLogout(completionHandlerLogout: { (error) in
            self.updateUIAfterLogout(error: error)
        })
    }
    
    @IBAction func performRefresh(_ sender: Any) {
        if (selectedIndex == 0) {
            let vc = selectedViewController as! MapViewController
            vc.getStudentsInfo("-updatedAt")
        }
        else {
            let vc = selectedViewController as! TableViewController
            vc.getStudentsInfo("-updatedAt")
        }
    }
    
    @IBAction func performAddStudent(_ sender: Any) {
        
        let studentsInfo = ParseClient.sharedInstance().studentsInfo!
        addStudentInfo(studentsInfo)
    }
    
    private func updateUIAfterLogout(error: NSError?) {
        
        performUIUpdatesOnMain {
            
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func addStudentInfo(_ studentInfo: [StudentInfo]) {
        var isExist: Bool = false
        let currentUserUniqueKey = UdacityClient.sharedInstance().AccountKey
        var currentStudent: StudentInfo?
        
        for studentInfo in studentInfo {
            if (studentInfo.UniqueKey == currentUserUniqueKey) {
                currentStudent = studentInfo
                isExist = true
                break
            }
        }
        
        if (isExist) {
            // create the alert
            let alert = UIAlertController(title: nil, message: "User \(currentStudent!.FirstName) \(currentStudent!.LastName) Has Already Posted a Student Location. Would You Like to Overwrite Their Location?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            let overWriteAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: {_ in
                self.presentAddStudentInfoView()
                })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
            //alert.view.tintColor = UIColor(rgb: 0x00ABE1)
            
            alert.addAction(overWriteAction)
            alert.addAction(cancelAction)
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else {
            presentAddStudentInfoView()
        }
    }
    
    private func presentAddStudentInfoView() {
        let updateLocationVC = self.storyboard!.instantiateViewController(withIdentifier: "AddNavigationController")
        self.present(updateLocationVC, animated: true, completion: nil)
    }
    
}
