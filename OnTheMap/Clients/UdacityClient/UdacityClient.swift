//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/30/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import UIKit

class UdacityClient {
    // shared session
    var session = URLSession.shared
    var AccountKey : String?
    var SessionID : String?
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    // Udacity Login
    func performUdacityLogin(_ email: String,
                             _ password: String,
                             completionHandlerLogin: @escaping (_ error: NSError?)
        -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.AuthorizationURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let _ = performRequest(request: request) { (parsedResult, error) in
            /* Send the values to completion handler */
            if let error = error {
                completionHandlerLogin(error)
            } else {
                /* GUARD: Look for account key in result */
                guard let accountDictionary = parsedResult?[UdacityClient.UdacityAccountKeys.Account] as? [String:AnyObject] else {
                    return
                }
                /* GUARD: Look for registered key in result */
                guard let registered = accountDictionary[UdacityClient.UdacityAccountKeys.Registered] as? Bool else {
                    return
                }
                /* GUARD: Look for account key in result */
                guard let accountKey = accountDictionary[UdacityClient.UdacityAccountKeys.Key] as? String else {
                    return
                }
                /* GUARD: Look for session key in result */
                guard let sessionDictionary = parsedResult?[UdacityClient.SessionKeys.Session] as? [String:AnyObject] else {
                    return
                }
                /* GUARD: Look for session id key in result */
                guard let sessionID = sessionDictionary[UdacityClient.SessionKeys.ID] as? String else {
                    return
                }
                // determine if account is registered. if failed notify user
                if registered {
                    self.AccountKey = accountKey
                    self.SessionID = sessionID
                    completionHandlerLogin(nil)
                }
                else {
                    let errorMsg = "Account not registered"
                    let userInfo = [NSLocalizedDescriptionKey : errorMsg]
                    completionHandlerLogin(NSError(domain: errorMsg, code: 2, userInfo: userInfo))
                }
            }
        }
    }
    // Udacity Logout
    func performUdacityLogout(completionHandlerLogout: @escaping (_ error: NSError?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.AuthorizationURL)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let _ = performRequest(request: request) { (parsedResult, error) in
            /* Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerLogout(error)
            } else {
                /* GUARD: Look for session key in result */
                guard let sessionDictionary = parsedResult?[UdacityClient.SessionKeys.Session] as? [String:AnyObject] else {
                    return
                }
                /* GUARD: look for session key in result? */
                guard let logoutSessionID = sessionDictionary[UdacityClient.SessionKeys.ID] as? String else {
                    return
                }
                // Do session ID's Match?
                if (logoutSessionID == self.SessionID!) {
                    completionHandlerLogout(nil)
                }
                else {
                    let errorMsg = "Invalid Session ID"
                    let userInfo = [NSLocalizedDescriptionKey : errorMsg]
                    completionHandlerLogout(NSError(domain: errorMsg, code: 3, userInfo: userInfo))
                }
                
            }
        }
    }
    // Udacity Login
    func performFacebookLogin(_ fbAccessToken: String,
                              completionHandlerFBLogin: @escaping (_ error: NSError?)
        -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.AuthorizationURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(fbAccessToken)\"}}".data(using: String.Encoding.utf8)
        let _ = performRequest(request: request) { (parsedResult, error) in
            /* Send the value to completion handler */
            if let error = error {
                completionHandlerFBLogin(error)
            } else {
                /* GUARD: Look for account key in result */
                guard let accountDictionary = parsedResult?[UdacityClient.UdacityAccountKeys.Account] as? [String:AnyObject] else {
                    return
                }
                /* GUARD: Look for registered key in result */
                guard let registered = accountDictionary[UdacityClient.UdacityAccountKeys.Registered] as? Bool else {
                    return
                }
                /* GUARD: Look for accunt key in result */
                guard let accountKey = accountDictionary[UdacityClient.UdacityAccountKeys.Key] as? String else {
                    return
                }
                /* GUARD: Look for session key in result */
                guard let sessionDictionary = parsedResult?[UdacityClient.SessionKeys.Session] as? [String:AnyObject] else {
                    return
                }
                /* GUARD: look for session id key in result */
                guard let sessionID = sessionDictionary[UdacityClient.SessionKeys.ID] as? String else {
                    return
                }
                // determine if account is registered. if failed notify user
                if registered {
                    self.AccountKey = accountKey
                    self.SessionID = sessionID
                    completionHandlerFBLogin(nil)
                }
                else {
                    // Account is not registered
                    let errorMsg = "Account not registered"
                    let userInfo = [NSLocalizedDescriptionKey : errorMsg]
                    completionHandlerFBLogin(NSError(domain: errorMsg, code: 2, userInfo: userInfo))
                }
            }
        }
    }
    private func performRequest(request: NSMutableURLRequest,
                                completionHandlerRequest: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
        -> URLSessionDataTask {
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                func sendError(_ error: String) {
                    print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerRequest(nil, NSError(domain: "performRequest", code: 1, userInfo: userInfo))
                }
                /* GUARD: Look for error */
                guard (error == nil) else {
                    sendError("Request failed. Please check your connection.")
                    return
                }
                /* GUARD: Did we get a successful response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    let httpError = (response as? HTTPURLResponse)?.statusCode
                    if httpError == 403 {
                        sendError("Invalid login and password")
                    }
                    else {
                        sendError("Your request returned status code : \(String(describing: httpError))")
                    }
                    return
                }
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    sendError("Request returned empty!")
                    return
                }
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
                
                self.convertDataWithCompletionHandler(newData, completionHandlerConvertData: completionHandlerRequest)
            }
            task.resume()
            return task
    }
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerConvertData(parsedResult, nil)
    }
}
