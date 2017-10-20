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
        
        // Create annotation from MKMapItem/s from localSearchResponse
        let location = OTMStudentInformation.init(createdAt: "",
                                                  updatedAt: "",
                                                  objectID: "",
                                                  firstName: localSearchResponse.mapItems.first!.placemark.title!,
                                                  lastName: "",
                                                  latitude: localSearchResponse.mapItems.first!.placemark.coordinate.latitude,
                                                  longitude: localSearchResponse.mapItems.first!.placemark.coordinate.longitude,
                                                  mapString: "",
                                                  mediaURL: mediaURLString ?? "",
                                                  uniqueKey: "")
        mapView.addAnnotation(location)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let annotation = mapView.annotations.first {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    @IBAction func setLocationTapped(_ sender: UIButton) {
        print("Set location tapped")
        // TODO: This should call the post locaiton method
    }
    
}

extension OTMAddLocationMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("An annotation was selected.")
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
            view.canShowCallout = true
        }
        
        return view
    }
}
