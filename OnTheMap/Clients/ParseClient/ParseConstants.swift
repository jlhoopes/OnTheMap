//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/30/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import Foundation

extension ParseClient {
    
    // MARK: Constants
    struct Constants {
        // MARK: API Key and Application ID
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
    }
    
    // MARK: Methods
    struct Methods {
        // MARK: StudentLocation
        static let StudentLocation = "/StudentLocation"
    }
    
    
    // MARK: Parameter Keys for GET Multiple Student Location
    struct MultipleStudentParameterKeys {
        
        // Multiple Student Locations
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    // MARK: Parameter Keys for GET One Student Location
    struct OneStudentParameterKeys {
        
        // One Student Location
        static let Where = "where"
    }
    
    // MARK: Parameter Keys for PUT Student Location
    struct OneStudentPutParameterKeys {
        
        static let ObjectID = "objectId"
    }
    
    // MARK: JSON Body Keys
    struct StudentJSONBodyKeys {
        
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    // MARK: JSON Response Keys
    struct GetStudentJSONResponseKeys {
        
        // MARK: Student Information
        static let StudentResult = "results"
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
    }
}

