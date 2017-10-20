import UIKit
import MapKit

/*
 {
 createdAt = "2017-10-12T15:24:43.801Z";
 objectId = 5kGzxjXAqv;
 updatedAt = "2017-10-12T15:24:43.801Z";
 },
 */

class OTMStudentInformation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    let createdAt: String
    let updatedAt: String
    let objectID: String
    
    let firstName: String
    let lastName: String
    
    let mapString: String?
    let mediaURL: String?
    let uniqueKey: String?
    
    init(createdAt: String, updatedAt: String, objectID: String, firstName: String, lastName: String, latitude: Double, longitude: Double, mapString: String?, mediaURL: String?, uniqueKey: String?) {
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.objectID = objectID
        
        self.firstName = firstName
        self.lastName = lastName
        
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.uniqueKey = uniqueKey
        
        // MKAnnotation protocol properties
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = "\(self.firstName) \(self.lastName)"
        self.subtitle = self.mediaURL
        
        super.init()
    }
}
