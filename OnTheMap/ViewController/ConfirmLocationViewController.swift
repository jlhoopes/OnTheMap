//
//  ConfirmLocationViewController.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 4/3/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController  {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var location: String!
    var latitude: Double?
    var longitude: Double?
    var mediaURL: String?
    var urlValid: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (mediaURL?.hasPrefix("https://"))! || (mediaURL?.hasPrefix("http://"))!{
            urlValid = true
        }
        if (urlValid == false){
            mediaURL = "http://\(mediaURL ?? "google.com")"
        }
        mapView.delegate = self
        updateMapView()
        
    }
    @IBAction func performCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func updateMapView(){
        activityIndicator.startAnimating()
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location){ (dropPins, error) in
            if (error == nil) {
                if ((dropPins?.count)! == 1) {
                    let dropPin = dropPins![0]
                    self.longitude = dropPin.location?.coordinate.longitude
                    self.latitude = dropPin.location?.coordinate.latitude
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
                    
                    // Set the coordinate span and map region
                    let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    let coordinateRegion = MKCoordinateRegion(center: coordinate, span: coordinateSpan)
                    
                    // Set the annotation
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    
                    performUIUpdatesOnMain {
                        self.mapView.region = coordinateRegion
                        self.mapView.addAnnotation(annotation)
                    }
                }
                else if ((dropPins?.count)! == 0){
                    self.performAlert("Location is Not Found")
                }
                else {
                    self.performAlert("Multiple Locations Found")
                }
            }
            else {
                self.performAlert("Error Getting Location")
            }
        }
    }
    
    @IBAction func performSubmit(_ sender: Any) {
        if let longitude = longitude {
            //print("Longitude")
            if let latitude = latitude {
                //print("Latitude")
                if let studentInfo = ParseClient.sharedInstance().studentInfo{
                    //print("Entering Student Info block")
                    var tempStudentInfo = studentInfo
                    tempStudentInfo.Longitude = longitude
                    tempStudentInfo.Latitude = latitude
                    tempStudentInfo.MediaURL = mediaURL!
                    tempStudentInfo.MapString = location
                    
                    if (studentInfo.Longitude != longitude || studentInfo.Latitude != latitude){
                        //print("performSubmit Put")
                        ParseClient.sharedInstance().putStudentInfo(studentInfo: tempStudentInfo, completionHandlerPutLocation: {(error) in
                            if (error == nil) {
                                performUIUpdatesOnMain{
                                    self.dismiss(animated: true, completion: nil)
                                }
                            } else {
                                self.performAlert("Failed to Update Student Information")
                            }
                        })
                    }
                    else {
                        //print("performSubmit post")
                        ParseClient.sharedInstance().postStudentInfo(studentInfo: tempStudentInfo, completionHandlerPostLocation: { (error) in
                            if (error == nil) {
                                performUIUpdatesOnMain{
                                    self.dismiss(animated: true, completion: nil)
                                }
                            } else {
                                self.performAlert("Failed to Create Student Information")
                            }
                        })
                    }
                }
            }
        }
    }
    // MARK: Handle Errors
    func performAlert(_ messageString: String, alertString: String = "") {
        performUIUpdatesOnMain {
            self.activityIndicator.stopAnimating()
            // Login fail
            let alert = UIAlertController(title: alertString, message: messageString, preferredStyle: UIAlertControllerStyle.alert),
            dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}

extension ConfirmLocationViewController: MKMapViewDelegate {
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if (fullyRendered) {
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
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
}
