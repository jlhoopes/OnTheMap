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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getStudentInformation("-updatedAt")
    }
    
    func getStudentInformation(_ updateAtString: String) {
        
        loadingIndicator.startAnimating()
        
        let parameters = [
            ParseClient.MultipleStudentParameterKeys.Limit: "100",
            ParseClient.MultipleStudentParameterKeys.Order: updateAtString
        ]
        
        ParseClient.sharedInstance().getStudentInformations(parameters: parameters as [String : AnyObject], completionHandlerLocations: { (studentInformation, error) in
            if let studentInformation = studentInformation{
                self.updateUIMapAnnotation(location: studentInformation)
            } else {
                self.performAlert("There was an error retrieving student data")
            }
        })
    }
    
    // The "locations" array is an array of dictionary objects that are similar to the JSON
    // data that you can download from parse.
    private func updateUIMapAnnotation(location: [StudentInformation]) {
        
        // clean up annotations first
        performUIUpdatesOnMain {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for dictionary in location {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            
            
            let lat = CLLocationDegrees(dictionary.Latitude as Double)
            let long = CLLocationDegrees(dictionary.Longitude as Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.FirstName as String
            let last = dictionary.LastName as String
            let mediaURL = dictionary.MediaURL as String
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            
            // just add to annotations when it has title and subtitle
            if (annotation.title != "" && annotation.subtitle != "") {
                annotations.append(annotation)
            }
        }
        
        performUIUpdatesOnMain {
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func performAlert(_ message: String) {
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
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
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}
