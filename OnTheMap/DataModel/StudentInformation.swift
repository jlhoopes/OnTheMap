//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/30/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

struct StudentInfo {
    
    // MARK: Properties
    
    let CreatedAt: String
    let FirstName: String
    let LastName: String
    var Latitude: Double
    var Longitude: Double
    var MapString: String
    var MediaURL: String
    let ObjectID: String
    let UniqueKey: String
    let UpdatedAt: String
    
    
    // MARK: Initializers
    
    // construct a StudentInfo block from a dictionary
    init?(dictionary: [String:AnyObject]) {
        
        if let createdAt = dictionary[ParseClient.GetStudentJSONResponseKeys.CreatedAt] as? String {
            CreatedAt = createdAt
        }
        else {
            return nil
        }
        
        if let firstName = dictionary[ParseClient.GetStudentJSONResponseKeys.FirstName] as? String {
            FirstName = firstName
        }
        else {
            return nil
        }
        
        if let lastName = dictionary[ParseClient.GetStudentJSONResponseKeys.LastName] as? String {
            LastName = lastName
        }
        else {
            return nil
        }
        
        if let latitude = dictionary[ParseClient.GetStudentJSONResponseKeys.Latitude] as? Double {
            Latitude = latitude
        }
        else {
            return nil
        }
        
        if let longitude = dictionary[ParseClient.GetStudentJSONResponseKeys.Longitude] as? Double {
            Longitude = longitude
        }
        else {
            return nil
        }
        
        if let mapString = dictionary[ParseClient.GetStudentJSONResponseKeys.MapString] as? String {
            MapString = mapString
        }
        else {
            return nil
        }
        
        if let mediaURL = dictionary[ParseClient.GetStudentJSONResponseKeys.MediaURL] as? String {
            MediaURL = mediaURL
        } else {
            return nil
        }
        
        if let objectID = dictionary[ParseClient.GetStudentJSONResponseKeys.ObjectID] as? String {
            ObjectID = objectID
        } else {
            return nil
        }
        
        if let uniqueKey = dictionary[ParseClient.GetStudentJSONResponseKeys.UniqueKey] as? String {
            UniqueKey = uniqueKey
        } else {
            return nil
        }
        
        if let updatedAt = dictionary[ParseClient.GetStudentJSONResponseKeys.UpdatedAt] as? String {
            UpdatedAt = updatedAt
        } else {
            return nil
        }
    }
    
    // Convert from array of strings to StudentsInfo object
    static func StudentsInfoFromResults(_ results: [[String:AnyObject]]) -> [StudentInfo] {
        
        var studentsInfo = [StudentInfo]()
        
        // iterate through array of dictionaries, each student is a dictionary
        for result in results {
            if let studentInfo = StudentInfo(dictionary: result) {
                studentsInfo.append(studentInfo)
            }
        }
        
        return studentsInfo
    }
}
