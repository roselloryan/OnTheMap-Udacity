import Foundation
import UIKit

struct Constants {
    
    struct HeaderKeys {
        static let AppID = "X-Parse-Application-Id"
        static let APIKey = "X-Parse-REST-API-Key"
        static let ContentType = "Content-Type"
        static let Accept = "Accept"
        static let CookieToken = "X-XSRF-TOKEN"
    }

    struct HeaderValues {
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApplicationJson = "application/json"
    }

    struct Url {
        static let ApiScheme = "https"
        static let ApiHost = "https://parse.udacity.com"
        static let ApiPath = "/parse/classes"
        static let UdacitySessionUrl = "https://www.udacity.com/api/session"
        static let StudentLocationsChronological = "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt"
    }
    
    struct HTTPBody {
        static let FacebookAccessTokenBody = "{\"facebook_mobile\": {\"access_token\": \"<TOKEN>\"}}"
    }
    
    struct HTTPMethod {
        static let Post = "POST"
        static let Delete = "DELETE"
    }
    
    struct DictionaryKey {
        static let Session = "session"
        static let ID = "id"
        static let Account = "account"
        static let Key = "key"
    }
    
    struct StudentInformationKey {
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let ObjectID =  "objectId"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let UniqueKey = "uniqueKey"
    }
    
    struct UserDefaultsKey {
        static let SessionID =  "sessionID"
        static let AccountKey = "accountKey"
    }
    
    struct Identifier {
        static let MainSegue = "mainSegue"
        static let TableViewCell = "studentLocationCell"
        static let CookieTokenName = "XSRF-TOKEN"
        static let AnnotationView = "annotationView"
        static let addLocationMapSeque = "addLocationMapSegue"
    }
    
    struct CustomColor {
        static let UdacityBlue = UIColor(red: 1/255, green: 179/255, blue: 228/255, alpha: 1)
    }
}

