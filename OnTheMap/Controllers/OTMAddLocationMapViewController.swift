import UIKit
import MapKit

class OTMAddLocationMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    var localSearchResponse: MKLocalSearchResponse!
    var mediaURLString: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        // Set visible region
        mapView.region = localSearchResponse.boundingRegion
        
        
        // TODO: Handle more than one mapItem possibity
        let locations = localSearchResponse.mapItems.map { (mapItem: MKMapItem) -> OTMStudentInformation in
            let newDict: Dictionary<String, Any> = [Constants.StudentInformationKey.CreatedAt : "",
                           Constants.StudentInformationKey.UpdatedAt : "",
                           Constants.StudentInformationKey.ObjectID : "",
                           Constants.StudentInformationKey.FirstName : mapItem.placemark.name ?? "",
                           Constants.StudentInformationKey.LastName : "",
                           Constants.StudentInformationKey.Latitude : mapItem.placemark.coordinate.latitude,
                           Constants.StudentInformationKey.Longitude : mapItem.placemark.coordinate.longitude,
                           Constants.StudentInformationKey.MapString : mapItem.placemark.name ?? "",
                           Constants.StudentInformationKey.MediaURL : mediaURLString ?? "",
                           Constants.StudentInformationKey.UniqueKey : ""]
            
            return OTMStudentInformation.init(withDictionary: newDict)
        }
        
        print(locations)
        mapView.addAnnotations(locations)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    
    // TODO: OMG This is big. Clean it up.
    
    // MARK: - Button methods
    @IBAction func setLocationTapped(_ sender: UIButton) {
        print("Set location tapped")
        
        guard let selectedPin = mapView.selectedAnnotations.first as? OTMStudentInformation else {
            print("No pin selected")
            presentAlertWith(title: "Please select a location pin", message: "")
            return
        }
        
        dimScreenWithActivitySpinner()
        
        // Find out if user already has location.
        OTMClient.shared.getSingleStudentLocation { [unowned self] (success, existingLocation, errorString) in
            
            if success {
                
                if existingLocation == nil {
                    print("We need to POST new location now!")
                    
                    // Call to POST new student location
                    OTMClient.shared.sendNewStudentLocationToAPI(withMethod: Constants.HTTPMethod.Post, studentLocation: selectedPin, postNewCompletionHandler: { (succcess, errorString) in
                        
                        DispatchQueue.main.async {
                            self.undimScreenAndRemoveActivitySpinner()
                            
                            if success {
                                
                                NotificationCenter.default.post(Constants.CustomNotification.UpdateNotification)
                                
                                // Successfully posted new location
                                let successAlert = UIAlertController(title: "Success!", message: "You are on the map", preferredStyle: .alert)
                                
                                self.present(successAlert, animated: true, completion: {
                                    
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                                        
                                        successAlert.dismiss(animated: true)
                                        
                                        self.presentingViewController?.dismiss(animated: true, completion: {
                                        })
                                    })
                                })
                            }
                            else {
                                // POST new location failed
                                self.presentAlertWith(title: errorString ?? "Unknown error", message: "")
                            }
                        }
                    })
                }
                // Student already on map and need to PUT to update location
                else {
                    
                    guard let existingLocation = existingLocation else {
                        print("No location returned from getSingleStudentLocation in add location map view controller")
                        return
                    }
                    
                    // Need the object ID to update location
                    selectedPin.objectID = existingLocation.objectID
                    
                    print(existingLocation.firstName +  " " + existingLocation.lastName)
                    
                    
                    OTMClient.shared.sendNewStudentLocationToAPI(withMethod: Constants.HTTPMethod.Put, studentLocation: selectedPin, postNewCompletionHandler: { (succcess, errorString) in
                        
                        DispatchQueue.main.async {
                            self.undimScreenAndRemoveActivitySpinner()
                            
                            if success {
                                NotificationCenter.default.post(Constants.CustomNotification.UpdateNotification)
                                
                                // Successfully updated location
                                let successAlert = UIAlertController(title: "Success!", message: "You've updated your location", preferredStyle: .alert)
                                
                                self.present(successAlert, animated: true, completion: { [unowned self] in
                                    
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                                        
                                        successAlert.dismiss(animated: true)
                                        
                                        self.presentingViewController?.dismiss(animated: true)
                                    })
                                })
                            }
                            else {
                                // Failed to PUT new location
                                self.presentAlertWith(title: errorString ?? "Unknown error", message: "")
                            }
                        }
                    })
                }
            }
            else if let errorString = errorString {
                
                DispatchQueue.main.async {
                    self.undimScreenAndRemoveActivitySpinner()
                    
                    // TODO: Flow options? Instructions
                    self.presentAlertWith(title: errorString, message: "")
                    print("No success in set location add location map controller")
                }
            }
            else {
                DispatchQueue.main.async {
                    self.undimScreenAndRemoveActivitySpinner()
                    print("Something went very wrong in setLocationTapped addLocationMapViewController")
                }
            }
        }
    }
    
}

// MARK: - Map View Delegate

extension OTMAddLocationMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        (view as! MKPinAnnotationView).pinTintColor = Constants.CustomColor.UdacityBlue
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        (view as! MKPinAnnotationView).pinTintColor = Constants.CustomColor.UdacityOrange
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? OTMStudentInformation else { return nil }
        
        var view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.Identifier.AnnotationView) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.Identifier.AnnotationView)
            view.pinTintColor = Constants.CustomColor.UdacityOrange
            view.canShowCallout = true
        }
        
        return view
    }
}
