//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Nicholas Sutanto on 9/14/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
    
    //var studentsInfo = [StudentInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getStudentsInfo()
    }
    
    private func updateTable() {
        performUIUpdatesOnMain {
            self.tableView.reloadData()
        }
    }
    
    func getStudentsInfo() {
        
        let parameters = [
            ParseClient.MultipleStudentParameterKeys.Limit: "100",
            ParseClient.MultipleStudentParameterKeys.Order: "updatedAt"
        ]
        
        ParseClient.sharedInstance().getStudentsInfo(parameters: parameters as [String : AnyObject], completionHandlerLocations: { (studentsInfo, error) in
            if let studentsInfo = studentsInfo {
                SharedData.sharedInstance.studentsInfo = studentsInfo
                self.updateTable()
            } else {
                self.performAlert("There was an error retrieving student data")
            }
        })
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let studentInfo = SharedData.sharedInstance.studentsInfo[(indexPath as NSIndexPath).row]
        if (studentInfo.MediaURL != "") {
            let app = UIApplication.shared
            app.open(URL(string: studentInfo.MediaURL)!, options: [:], completionHandler: { (isSuccess) in
                
                if (isSuccess == false) {
                    self.performAlert("Link URL is not valid. It might missing http or https.")
                }
            })
        }
        else {
            let alert = UIAlertController(title: "Alert", message: "Link URL is not valid", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedData.sharedInstance.studentsInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let studentInfo = SharedData.sharedInstance.studentsInfo[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentInfoCell", for: indexPath)
        cell.textLabel!.text = studentInfo.FirstName + " " + studentInfo.LastName
        cell.detailTextLabel!.text = studentInfo.MediaURL
        
        return cell
    }
    
    func performAlert(_ message: String) {
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
