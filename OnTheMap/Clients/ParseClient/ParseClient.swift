//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/30/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import UIKit

class ParseClient {
    // shared session
    
    var session = URLSession.shared
    
    var studentInfo : StudentInfo?
    var studentsInfo: [StudentInfo]?
    
    // MARK: Shared Instance Singleton
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    // GET student groupings
    func getStudentsInfo(parameters: [String: AnyObject], completionHandlerLocations: @escaping (_ result: [StudentInfo]?, _ error: NSError?)
        -> Void) {
        
        let request = NSMutableURLRequest(url: parseURLFromParameters(parameters, withPathExtension: Methods.StudentLocation))
        
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            if let error = error {
                completionHandlerLocations(nil, error)
            } else {
                
                if let results = parsedResult?[GetStudentJSONResponseKeys.StudentResult] as? [[String:AnyObject]] {
                    
                    self.studentsInfo = StudentInfo.StudentsInfoFromResults(results)
                    
                    SharedData.sharedInstance.studentsInfo = self.studentsInfo!
                    completionHandlerLocations(self.studentsInfo, nil)
                } else {
                    completionHandlerLocations(nil, NSError(domain: "parse getStudentLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    // GET a single student
    func getStudentInfo(completionHandlerLocation: @escaping (_ result: StudentInfo?, _ error: NSError?)
        -> Void) {
        
        // Get Current User / Student Info
        let accountKey = UdacityClient.sharedInstance().AccountKey
        let uniqueKeyStr = "{\"uniqueKey\":\"" + accountKey! + "\"}"
        let customAllowedSet =  CharacterSet(charactersIn:":=\"#%/<>?@\\^`{|}").inverted
        let accountKeyEscapedString = uniqueKeyStr.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        let parameters = [OneStudentParameterKeys.Where: accountKeyEscapedString as AnyObject]
        let uniqueKey = parameters[OneStudentParameterKeys.Where] as? String
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=" + uniqueKey!)!)
        
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let _ = performRequest(request: request) { (parsedResult, error) in
            if let error = error {
                completionHandlerLocation(nil, error)
            } else {
                
                if let results = parsedResult?[GetStudentJSONResponseKeys.StudentResult] as? [[String:AnyObject]] {
                    
                    let studentsInfo = StudentInfo.StudentsInfoFromResults(results)
                    
                    if (studentsInfo.count > 0) {
                        self.studentInfo = studentsInfo[0]
                        SharedData.sharedInstance.currentUser = self.studentInfo!
                        completionHandlerLocation(self.studentInfo, nil)
                    }
                } else {
                    completionHandlerLocation(nil, NSError(domain: "parse getStudentInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    // MARK: Post Student Location
    func postStudentInfo(studentInfo: StudentInfo, completionHandlerPostLocation: @escaping (_ error: NSError?) -> Void) {
        //print("posting")
        let request = NSMutableURLRequest(url: parseURLFromParameters(nil, withPathExtension: Methods.StudentLocation))
        
        request.httpMethod = "POST"
        
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(studentInfo.UniqueKey)\", \"firstName\": \"\(studentInfo.FirstName)\", \"lastName\": \"\(studentInfo.LastName)\",\"mapString\": \"\(studentInfo.MapString)\", \"mediaURL\": \"\(studentInfo.MediaURL)\",\"latitude\": \(studentInfo.Latitude), \"longitude\": \(studentInfo.Longitude)}".data(using: String.Encoding.utf8)
        
        let _ = performRequest(request: request) { (parsedResult, error) in
            if let error = error {
                completionHandlerPostLocation(error)
            } else {
                
                // GUARD: is the createdAt key present?
                guard let createdAt = parsedResult?[GetStudentJSONResponseKeys.CreatedAt] as? String else {
                    completionHandlerPostLocation(NSError(domain: "postStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST Student Location"]))
                    return
                }
                // GUARD: is the objectID key present?
                guard let objectID = parsedResult?[GetStudentJSONResponseKeys.ObjectID] as? String else {
                    completionHandlerPostLocation(NSError(domain: "postStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST Student Location"]))
                    return
                }
                if (objectID != "" && createdAt != "") {
                    completionHandlerPostLocation(nil)
                } else {
                    completionHandlerPostLocation(NSError(domain: "postStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST Student Location"]))
                }
            }
        }
    }
    
    // MARK: Put Student Location
    func putStudentInfo(studentInfo: StudentInfo, completionHandlerPutLocation: @escaping (_ error: NSError?) -> Void) {
        //print("putting")
        let request = NSMutableURLRequest(url: parseURLFromParameters(nil, withPathExtension: Methods.StudentLocation + "/\(studentInfo.ObjectID)"))
        
        request.httpMethod = "PUT"
        
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(studentInfo.UniqueKey)\", \"firstName\": \"\(studentInfo.FirstName)\", \"lastName\": \"\(studentInfo.LastName)\",\"mapString\": \"\(studentInfo.MapString)\", \"mediaURL\": \"\(studentInfo.MediaURL)\",\"latitude\": \(studentInfo.Latitude), \"longitude\": \(studentInfo.Longitude)}".data(using: String.Encoding.utf8)
        
        
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            if let error = error {
                completionHandlerPutLocation(error)
            } else {
                
                // GUARD: is the updatedAt key present?
                guard let updatedAt = parsedResult?[GetStudentJSONResponseKeys.UpdatedAt] as? String else {
                    completionHandlerPutLocation(NSError(domain: "PUT StudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse PUT Student Location"]))
                    return
                }
                
                if updatedAt != "" {
                    completionHandlerPutLocation(nil)
                } else {
                    completionHandlerPutLocation(NSError(domain: "PUT StudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse PUT Student Location"]))
                }
            }
        }
    }
    
    // MARK: Perform request
    private func performRequest(request: NSMutableURLRequest,
                                completionHandlerRequest: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
        -> URLSessionDataTask {
            
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                
                func sendError(_ error: String) {
                    //print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerRequest(nil, NSError(domain: "performRequest", code: 1, userInfo: userInfo))
                }
                // GUARD: was there an error?
                guard (error == nil) else {
                    sendError("There was an error with your request: \(error!)")
                    return
                }
                // GUARD: Did we get a successful response?
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    let httpError = (response as? HTTPURLResponse)?.statusCode
                    sendError("Your request returned a status code : \(String(describing: httpError))")
                    return
                }
                // GUARD: Was data returned?
                guard let data = data else {
                    sendError("No data was returned by the request!")
                    return
                }
                self.convertDataWithCompletionHandler(data, completionHandlerConvertData: completionHandlerRequest)
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
    
    // create a URL from parameters
    private func parseURLFromParameters(_ parameters: [String:AnyObject]?, withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
}
