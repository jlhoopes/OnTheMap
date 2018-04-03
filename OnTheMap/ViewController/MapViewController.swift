//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 4/2/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getStudentInfo("-updatedAt")
    }
    
    func getStudentInfo(_ updateAtString: String) {
        
        activityIndicator.startAnimating()
        
        let parameters = [
            ParseClient.MultipleStudentParameterKeys.Limit: "50",
            ParseClient.MultipleStudentParameterKeys.Order: updateAtString
        ]
        
        ParseClient.sharedInstance().getStudentsInfo(parameters: parameters as [String : AnyObject], completionHandlerLocations: { (studentInfo, error) in
            if let studentInfo = studentInfo{
                self.updateUIMapAnnotation(location: studentInfo)
            } else {
                self.performAlert("There was an error retrieving student data")
            }
        })
    }
    
    // The location array is populated with JSON results from student dictionaries
    private func updateUIMapAnnotation(location: [StudentInfo]) {
        
        // clean up annotations first
        performUIUpdatesOnMain {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        // Create MKPointAnnotation array container for annotations
        var annotations = [MKPointAnnotation]()
        
        
        // Populate annotations with results in the dictionary returns
        
        for dictionary in location {
            // Process student names, locations, and URL
            let lat = CLLocationDegrees(dictionary.Latitude as Double)
            let long = CLLocationDegrees(dictionary.Longitude as Double)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let first = dictionary.FirstName as String
            let last = dictionary.LastName as String
            let mediaURL = dictionary.MediaURL as String
            
            // Create each annotation using student data
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Add non blank annotations
            if (annotation.title != "" && annotation.subtitle != "") {
                annotations.append(annotation)
            }
        }
        
        performUIUpdatesOnMain {
            // Append map annotations
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func performAlert(_ message: String) {
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert),
                okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK Map view extensions
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }
    
    // Method for url pass to safari
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: { (isSuccess) in
                    
                    if (isSuccess == false) {
                        self.performAlert("Link URL is not valid. It might missing http or https.")
                    }
                }
                )}
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if (fullyRendered) {
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
