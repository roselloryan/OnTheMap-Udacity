import UIKit

// Parse Application ID: QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr
// REST API Key: QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY

class OTMClient: NSObject {

    static let shared = OTMClient()
    
    var session = URLSession.shared
    var sessionID: String? = nil
    var accountKey: Int? = nil
    
    
    func getSessionIDWith(email: String, password: String, completionHandler: @escaping(_ success: Bool, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: Constants.Url.UdacitySessionUrl)!)
        request.httpMethod = Constants.HTTPMethod.Post
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { [unowned self] data, response, error in
            
            guard (error == nil) else {
                print("There was an error in getSessionID request: \(error!.localizedDescription))")
                completionHandler(false, error!.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("No data in getSessionIdWith()")
                completionHandler(false, "No data returned in getSessionIdWith()")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                print("No response returned in getSessionIdWith()")
                completionHandler(false, "No response returned in getSessionIdWith()")
                return
            }
            guard statusCode >= 200, statusCode <= 299 else {
                print("Unsuccessful status code in getSessionIdWith() statusCode: \((response as! HTTPURLResponse).statusCode)")
                
                // Failed post: {"status": 403, "error": "Account not found or invalid credentials."}
                if statusCode == 403 {
                    completionHandler(false, "Account not found or invalid username/password")
                    return
                }
                else {
                    completionHandler(false, "Unknown error")
                    return
                }
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { [unowned self] (result, error) in
                
                if let error = error {
                    completionHandler(false, error.localizedDescription)
                    return
                }
                
                // Handle parsed response
                if let sessionID = ((result as! NSDictionary)[Constants.DictionaryKey.Session] as! NSDictionary)[Constants.DictionaryKey.ID] as? String {
                    self.sessionID = sessionID
                    UserDefaults.standard.set(sessionID, forKey: Constants.UserDefaultsKey.SessionID)
                }
                else {
                    //TODO: Handle issue
                    // What does a bad response look like?
                }
                
                if let accountKey = ((result as! NSDictionary)[Constants.DictionaryKey.Account] as! NSDictionary)[Constants.DictionaryKey.Key] as? Int {
                    self.accountKey = accountKey
                    UserDefaults.standard.set(accountKey, forKey: Constants.UserDefaultsKey.AccountKey)
                }
                else {
                    //TODO: Handle issue
                    // What does a bad response look like?
                }
                
                completionHandler(true, nil)
            })
        }
        
        task.resume() 
    }
    
    func getSessionIDWithFacebookAccessToken(_ token: String, completionHandler: @escaping(_ success: Bool, _ errorString: String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.Url.UdacitySessionUrl)!)
        request.httpMethod = Constants.HTTPMethod.Post
        request.addValue(Constants.HeaderValues.ApplicationJson, forHTTPHeaderField: Constants.HeaderKeys.Accept)
        request.addValue(Constants.HeaderValues.ApplicationJson, forHTTPHeaderField: Constants.HeaderKeys.ContentType)
        request.httpBody = Constants.HTTPBody.FacebookAccessTokenBody.replacingOccurrences(of: "<TOKEN>", with: token).data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { [unowned self] data, response, error in
            
            if let error = error {
                completionHandler(false, error.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200, statusCode <= 299 else {
                print(response!)
                completionHandler(false, "there was no response in getSessionIDWithFacebookAccessToken")
                return
            }
            
            guard let data = data else {
                completionHandler(false, "No data returned in getSessionIDWithFacebookAccessToken")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { [unowned self] (result, error) in
               
                if let error = error {
                    completionHandler(false, error.localizedDescription)
                    return
                }
                
                // Handle parsed response
                if let sessionID = ((result as! NSDictionary)[Constants.DictionaryKey.Session] as! NSDictionary)[Constants.DictionaryKey.ID] as? String {
                    self.sessionID = sessionID
                }
                else {
                    //TODO: Handle issue
                    // What does a bad response look like?
                }
                
                if let accountKey = ((result as! NSDictionary)[Constants.DictionaryKey.Account] as! NSDictionary)[Constants.DictionaryKey.Key] as? Int {
                    self.accountKey = accountKey
                }
                else {
                    //TODO: Handle issue
                    // What does a bad response look like?
                }
                
                completionHandler(true, nil)
            })
        }
        
        task.resume()
    }
    
    
    func getStudentLocationsInDateOrder(locationsCompletionHandler: @escaping (_ success: Bool, _ resultsArray: Array<OTMStudentInformation>?, _ errorString: String? ) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: Constants.Url.StudentLocationsChronological)!)
        request.addValue(Constants.HeaderValues.AppID, forHTTPHeaderField: Constants.HeaderKeys.AppID)
        request.addValue(Constants.HeaderValues.APIKey, forHTTPHeaderField: Constants.HeaderKeys.APIKey)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // Check error
            if let error = error {
                locationsCompletionHandler(false, nil, error.localizedDescription)
                return
            }
            
            // Check status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200, statusCode <= 299 else {
                print("Unsuccesful resopnse code in getStudentLocationsInDateOrder\n\(String(describing:response!))")
                locationsCompletionHandler(false, nil, "Unsuccesful resopnse status code in getStudentLocationsInDateOrder")
                return
            }
            
            // Check Data
            guard let data = data else {
                locationsCompletionHandler(false, nil, "No data returned in getStudentLocationsInDateOrder")
                return
            }
            
            // Parse results
            var parsedResult: AnyObject! = nil
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            }
            catch {
                print("Could not parse data in getStudentLocationsInDateOrder")
                locationsCompletionHandler(false, nil, "Could not parse data in getStudentLocationsInDateOrder")
                return
            }
            
            // Use results
            if let locationsDict = (parsedResult as! NSDictionary)["results"] as? NSArray {
                
                let locationsArray = self.convertDictionaryToStudentLocationObjectsInSharedData(locationsDict)
                
                locationsCompletionHandler(true, locationsArray, nil)
            }
        }
        
        task.resume()
    }
    
    func deleteUdacitySession(_ deleteSessionCompletionHandler: @escaping(_ success: Bool, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: Constants.Url.UdacitySessionUrl)!)
        request.httpMethod = Constants.HTTPMethod.Delete
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared

        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == Constants.Identifier.CookieTokenName {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: Constants.HeaderKeys.CookieToken)
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { [unowned self] data, response, error in
            
            // Check error
            if let error = error {
                // Handle error…
                deleteSessionCompletionHandler(false, error.localizedDescription)
                return
            }
            
            // Check status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200, statusCode <= 299 else {
                print("Unsuccesful resopnse code in deleteUdacitySession\n\(String(describing:response!))")
                deleteSessionCompletionHandler(false, "Unsuccessful status code in deleteUdacitySession")
                return
            }
            
            // Check Data
            guard let data = data else {
                deleteSessionCompletionHandler(false, "No data returned in deleteUdacitySession")
                return
            }
            
            
            // Parse data
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (result, error) in
                
                if let error = error {
                    deleteSessionCompletionHandler(false, error.localizedDescription)
                    return
                }
                
                if let result = result {
                    // TODO: What do we want from the delete parsed result? Success?
                    print("Result from delete Udacity session:")
                    print(result)
                    deleteSessionCompletionHandler(true, nil)
                }
            })
        }
        task.resume()
        
    }
    
    func logoutFacebookSession() {
        
    }
    
    // MARK: JSON Parsing Method
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        print(parsedResult)
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: Populated Shared Data Method
    func convertDictionaryToStudentLocationObjectsInSharedData(_ locationsArray: NSArray) -> [OTMStudentInformation] {
        var tempArray = [OTMStudentInformation]()
        
        for location in locationsArray {
            
            let location = location as! NSDictionary
//            print(location)
            
            if let latitude = location[Constants.StudentInformationKey.Latitude] as? Double,
                let longitude = location[Constants.StudentInformationKey.Longitude] as? Double,
                let firstName = location[Constants.StudentInformationKey.FirstName] as? String,
                let lastName = location[Constants.StudentInformationKey.LastName] as? String {
                
                let newLocation = OTMStudentInformation(createdAt: location[Constants.StudentInformationKey.CreatedAt] as! String,
                                                     updatedAt: location[Constants.StudentInformationKey.UpdatedAt]  as! String,
                                                     objectID: location[Constants.StudentInformationKey.ObjectID]  as! String,
                                                     firstName: firstName,
                                                     lastName: lastName,
                                                     latitude: latitude,
                                                     longitude: longitude,
                                                     mapString: location[Constants.StudentInformationKey.MapString] as? String,
                                                     mediaURL: location[Constants.StudentInformationKey.MediaURL] as? String,
                                                     uniqueKey: location[Constants.StudentInformationKey.UniqueKey] as? String)
                
                tempArray.append(newLocation)
            }
        }
        
        print(tempArray.count)
        return tempArray
    }
}





