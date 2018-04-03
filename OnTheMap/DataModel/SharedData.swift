//
//  SharedData.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/30/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import Foundation
class SharedData{
    
    static let sharedInstance = SharedData()
    var studentsInfo: [StudentInfo] = []
    var currentUser: StudentInfo?
    
    private init() {}
}
