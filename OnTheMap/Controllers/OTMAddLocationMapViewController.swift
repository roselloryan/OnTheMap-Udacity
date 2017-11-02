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
        
//        if let annotation = mapView.annotations.first {
//            mapView.selectAnnotation(annotation, animated: true)
//        }
    }
    
    
    // MARK: - Button methods
    @IBAction func setLocationTapped(_ sender: UIButton) {
        print("Set location tapped")
        
        // TODO: This should call the PUT or POST locaiton methods
        
        guard let selectedPin = mapView.selectedAnnotations.first as? OTMStudentInformation else {
            print("No pin selected")
            presentAlertWith(title: "Please select a location pin", message: "")
            return
        }
        
        // TODO: Set mapString and url before passing StudentInformation to post method
        
        // 0. Find out if user already has location.
        OTMClient.shared.getSingleStudentLocation { [unowned self] (success, existingLocation, errorString) in
            
            if success {
                
                if existingLocation == nil {
                    print("We need to POST new location now!")
                    
                    // Call to POST new student location
                    OTMClient.shared.postNewStudentLocation(selectedPin, postNewCompletionHandler: { (succcess, errorString) in
                        if success {
                            // TODO: Present success alert
                        }
                        else {
                            self.presentAlertWith(title: errorString ?? "Unknown error", message: "")
                        }
                    })
                }
                else {
                    // Update PUT existing student location
                    guard let existingLocation = existingLocation else {
                        print("No location returned from getSingleStudentLocation in add location map view controller")
                        return
                    }
                    print(existingLocation.firstName +  existingLocation.lastName)
                }
                
                // 2. Call post method on chare OTMClient
                
                // 3. Handle success or failures
                
                // 4. navigate back to map view in tabBarController
            }
            else if let errorString = errorString {
                // TODO: Flow options?
                self.presentAlertWith(title: errorString, message: "")
                print("No success in set location add location map controller")
            }
        }
    }
    
}

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
