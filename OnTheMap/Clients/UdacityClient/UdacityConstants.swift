//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/30/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        static let AuthorizationURL = "https://www.udacity.com/api/session"
    }
    
    // MARK: Parameters
    struct UdacityParameterKeys {
        
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct UdacityAccountKeys {
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
    }
    
    struct SessionKeys {
        static let Session = "session"
        static let ID = "id"
        static let Expiration = "expiration"
    }
}
