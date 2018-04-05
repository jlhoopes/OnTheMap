//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/30/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import UIKit

class UdacityClient {
    var session = URLSession.shared
    var AccountKey : String?
    var SessionID : String?
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
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
            if let error = error {
                completionHandlerLogin(error)
            } else {
                guard let accountDictionary = parsedResult?[UdacityClient.UdacityAccountKeys.Account] as? [String:AnyObject] else {
                    return
                }
                guard let registered = accountDictionary[UdacityClient.UdacityAccountKeys.Registered] as? Bool else {
                    return
                }
                guard let accountKey = accountDictionary[UdacityClient.UdacityAccountKeys.Key] as? String else {
                    return
                }
                guard let sessionDictionary = parsedResult?[UdacityClient.SessionKeys.Session] as? [String:AnyObject] else {
                    return
                }
                guard let sessionID = sessionDictionary[UdacityClient.SessionKeys.ID] as? String else {
                    return
                }
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
            if let error = error {
                completionHandlerLogout(error)
            } else {
                guard let sessionDictionary = parsedResult?[UdacityClient.SessionKeys.Session] as? [String:AnyObject] else {
                    return
                }
                guard let logoutSessionID = sessionDictionary[UdacityClient.SessionKeys.ID] as? String else {
                    return
                }
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
    // Facebook Login
    func performFacebookLogin(_ fbAccessToken: String,
                              completionHandlerFBLogin: @escaping (_ error: NSError?)
        -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.AuthorizationURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(fbAccessToken)\"}}".data(using: String.Encoding.utf8)
        let _ = performRequest(request: request) { (parsedResult, error) in
            if let error = error {
                completionHandlerFBLogin(error)
            } else {
                guard let accountDictionary = parsedResult?[UdacityClient.UdacityAccountKeys.Account] as? [String:AnyObject] else {
                    return
                }
                guard let registered = accountDictionary[UdacityClient.UdacityAccountKeys.Registered] as? Bool else {
                    return
                }
                guard let accountKey = accountDictionary[UdacityClient.UdacityAccountKeys.Key] as? String else {
                    return
                }
                guard let sessionDictionary = parsedResult?[UdacityClient.SessionKeys.Session] as? [String:AnyObject] else {
                    return
                }
                guard let sessionID = sessionDictionary[UdacityClient.SessionKeys.ID] as? String else {
                    return
                }
                if registered {
                    self.AccountKey = accountKey
                    self.SessionID = sessionID
                    completionHandlerFBLogin(nil)
                }
                else {
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
                    //print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerRequest(nil, NSError(domain: "performRequest", code: 1, userInfo: userInfo))
                }
                
                guard (error == nil) else {
                    sendError("Request failed. Please check your connection.")
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    let httpError = (response as? HTTPURLResponse)?.statusCode
                    if httpError == 403 {
                        sendError("Invalid Email or Password")
                    }
                    else {
                        sendError("Your request returned status code : \(String(describing: httpError))")
                    }
                    return
                }
                
                guard let data = data else {
                    sendError("Request Returned Empty")
                    return
                }
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                
                self.convertDataWithCompletionHandler(newData, completionHandlerConvertData: completionHandlerRequest)
            }
            task.resume()
            return task
    }
    
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
