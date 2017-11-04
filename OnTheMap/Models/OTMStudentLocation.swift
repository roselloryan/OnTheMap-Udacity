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
    
    var createdAt: String
    var updatedAt: String
    var objectID: String
    var uniqueKey: String
    
    var firstName: String
    var lastName: String
    
    var mapString: String?
    var mediaURL: String?
    
    
    init(createdAt: String, updatedAt: String, objectID: String, firstName: String, lastName: String, latitude: Double, longitude: Double, mapString: String?, mediaURL: String?, uniqueKey: String) {
        
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
    
    convenience init(withDictionary dict: Dictionary<String,Any>) {
        self.init(createdAt: dict[Constants.StudentInformationKey.CreatedAt] as! String,
                  updatedAt: dict[Constants.StudentInformationKey.UpdatedAt] as! String,
                  objectID: dict[Constants.StudentInformationKey.ObjectID] as! String,
                  firstName: dict[Constants.StudentInformationKey.FirstName] as! String,
                  lastName: dict[Constants.StudentInformationKey.LastName] as! String,
                  latitude: dict[Constants.StudentInformationKey.Latitude] as! Double,
                  longitude: dict[Constants.StudentInformationKey.Longitude] as! Double,
                  mapString: dict[Constants.StudentInformationKey.MapString] as? String,
                  mediaURL: dict[Constants.StudentInformationKey.MediaURL] as? String,
                  uniqueKey: dict[Constants.StudentInformationKey.UniqueKey] as! String)
    }
}
