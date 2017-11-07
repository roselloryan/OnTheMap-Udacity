import UIKit
import FacebookCore

// Parse Application ID: QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr
// REST API Key: QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY

class OTMClient: NSObject {

    static let shared = OTMClient()
    
    var session = URLSession.shared
    var sessionID: String? = nil
    var sessionExpirationDate: String? = nil
    var accountKey: String? = nil
    
    
    func getSessionIDWith(email: String, password: String, completionHandler: @escaping(_ success: Bool, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: Constants.Url.UdacitySessionUrl)!)
        
        request.httpMethod = Constants.HTTPMethod.Post
        request.addValue(Constants.HeaderValues.ApplicationJson, forHTTPHeaderField: Constants.HeaderKeys.Accept)
        request.addValue(Constants.HeaderValues.ApplicationJson, forHTTPHeaderField: Constants.HeaderKeys.ContentType)
        
        let bodyString = Constants.HTTPBody.SessionIDBody.replacingOccurrences(of: Constants.HTTPBody.EmailToken, with: email).replacingOccurrences(of: Constants.HTTPBody.PasswordToken, with: password)
        request.httpBody = bodyString.data(using: .utf8)

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
                guard let sessionDict = ((result as! NSDictionary)[Constants.DictionaryKey.Session] as? NSDictionary) else {
                    completionHandler(false, "No session dictionary in getSessionIdWith(email:password:)")
                    return
                }
                
                guard let accountDict = ((result as! NSDictionary)[Constants.DictionaryKey.Account] as? NSDictionary) else {
                    completionHandler(false, "No account dictionary in getSessionIdWith(email:password:)")
                    return
                }
                
                guard let sessionID = sessionDict[Constants.DictionaryKey.ID] as? String  else {
                    //TODO: Handle issue
                    // What does a bad response look like?
                    completionHandler(false, "Did not recive session id in getSessionIdWith(email:password:)")
                    return
                }
                
                guard let accountKey = accountDict[Constants.DictionaryKey.Key] as? String else {
                    //TODO: Handle issue
                    // What does a bad response look like?
                    completionHandler(false, "Did not recive Account key in getSessionIdWith(email:password:)")
                    return
                }
                
                guard let expirationDate = sessionDict[Constants.DictionaryKey.ExpirationDate] as? String else {
                    completionHandler(false, "No expiration date in getSessionIdWith(email:password:)")
                    return
                }
                
                self.sessionID = sessionID
                self.accountKey = accountKey
                self.sessionExpirationDate = expirationDate
                self.addSessionIDExpirationDateAndAccountKeyToUserDefaults(sessionID: sessionID, expirationDate: expirationDate, acountKey: accountKey)
                
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
                guard let sessionDict = ((result as! NSDictionary)[Constants.DictionaryKey.Session] as? NSDictionary) else {
                    completionHandler(false, "No session dictionary in getSessionIdWith(email:password:)")
                    return
                }
                
                guard let accountDict = ((result as! NSDictionary)[Constants.DictionaryKey.Account] as? NSDictionary) else {
                    completionHandler(false, "No session dictionary in getSessionIdWith(email:password:)")
                    return
                }
                
                guard let sessionID = sessionDict[Constants.DictionaryKey.ID] as? String else {
                    
                    //TODO: Handle issue
                    // What does a bad response look like?
                    completionHandler(false, "No session id in getSessionIDWithFacebookAccessToken()")
                    return
                }
                
                guard let expirationDate = sessionDict[Constants.DictionaryKey.ExpirationDate] as? String else {
                    completionHandler(false, "No expiration date in getSessionIDWithFacebookAccessToken()")
                    return
                }
                
                
                guard let accountKey = accountDict[Constants.DictionaryKey.Key] as? String else {
                    //TODO: Handle issue
                    // What does a bad response look like?
                    completionHandler(false, "No account key in getSessionIDWithFacebookAccessToken()")
                    return
                }
                
                self.sessionID = sessionID
                self.accountKey = accountKey
                self.sessionExpirationDate = expirationDate
                self.addSessionIDExpirationDateAndAccountKeyToUserDefaults(sessionID: sessionID, expirationDate:    expirationDate, acountKey: accountKey)
                
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
    
    func getSingleStudentLocation(locationsCompletionHandler: @escaping (_ success: Bool, _ results: OTMStudentInformation?, _ errorString: String? ) -> Void) {
        
        guard let accountKey = UserDefaults.standard.object(forKey: Constants.UserDefaultsKey.AccountKey) as? String else {
            print("No accountKey in userDefaults OTMClient getSingleStudentLocation")
            // TODO: handle no acount key error?
            return
        }
         
//        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22" + accountKey + "%22%7D"
        let urlString = Constants.Url.SingleStudentLocation.replacingOccurrences(of: Constants.Url.AccountKeyToken, with: accountKey)
        
        //Test URL
//        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22" + "10529458535" + "%22%7D"
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
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
                print("Unsuccesful resopnse code in getSingleStudentLocation\n\(String(describing:response!))")
                locationsCompletionHandler(false, nil, "Unsuccesful resopnse status code in getSingleStudentLocation")
                return
            }
            
            // Check Data
            guard let data = data else {
                locationsCompletionHandler(false, nil, "No data returned in getSingleStudentLocation")
                return
            }
            
            // Parse results
            var parsedResult: AnyObject! = nil
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            }
            catch {
                print("Could not parse data in getSingleStudentLocation")
                locationsCompletionHandler(false, nil, "Could not parse data in getSingleStudentLocation")
                return
            }
            
            // Use results
            if let locationsDict = (parsedResult as! NSDictionary)["results"] as? NSArray {
                
                let locationsArray = self.convertDictionaryToStudentLocationObjectsInSharedData(locationsDict)
                
                if let location = locationsArray.first {
                    locationsCompletionHandler(true, location, nil)
                }
                else {
                    // This means no location already in API for userID
                    locationsCompletionHandler(true, nil, "emtpy locations array in getSingleStudentLocation")
                }
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

                    print("Result from delete Udacity session:\n\(result)")
                    deleteSessionCompletionHandler(true, nil)
                }
            })
        }
        task.resume()
        
    }
    
    func sendNewStudentLocationToAPI(withMethod httpMethod: String, studentLocation: OTMStudentInformation,  postNewCompletionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        OTMClient.shared.getUserInfo { (userInfoDict, errorString) in
            
            if let errorString = errorString {
                postNewCompletionHandler(false, errorString)
                return
            }
            
            print(Constants.Url.ApiHost + Constants.Url.ApiPath + Constants.Url.StudentLocationsPath)
            
            guard let userInfoDict = userInfoDict else {
                postNewCompletionHandler(false, "Error in postNewStudentLocation")
                return
            }
            
            guard let firstName = userInfoDict["first_name"] as? String,
                let lastName = userInfoDict["last_name"]  as? String,
                let key = userInfoDict["key"] as? String else {
                    
                    postNewCompletionHandler(false, "Error in userInfoDict in postNewStudentLocation")
                    return
            }
            
            guard let url = URL(string: Constants.Url.ApiHost + Constants.Url.ApiPath + Constants.Url.StudentLocationsPath + (httpMethod == Constants.HTTPMethod.Put ? "/" + studentLocation.objectID : "")) else {
                postNewCompletionHandler(false, "URL failed...")
                return
            }
            
            print(url.absoluteString)
            
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
            request.addValue( Constants.HeaderValues.AppID, forHTTPHeaderField: Constants.HeaderKeys.AppID)
            request.addValue(Constants.HeaderValues.APIKey, forHTTPHeaderField: Constants.HeaderKeys.APIKey)
            request.addValue(Constants.HeaderValues.ApplicationJson, forHTTPHeaderField: Constants.HeaderKeys.ContentType)
            
            var httpBodyString = Constants.HTTPBody.PostLocationBody
            httpBodyString = httpBodyString.replacingOccurrences(of: Constants.HTTPBody.UniqueKeyToken, with: key)
            httpBodyString = httpBodyString.replacingOccurrences(of: Constants.HTTPBody.FirstNameToken, with: firstName)
            httpBodyString = httpBodyString.replacingOccurrences(of: Constants.HTTPBody.LastNameToken, with: lastName)
            httpBodyString = httpBodyString.replacingOccurrences(of: Constants.HTTPBody.MapStringToken, with: studentLocation.mapString ?? "")
            httpBodyString = httpBodyString.replacingOccurrences(of: Constants.HTTPBody.MediaURLToken, with: studentLocation.mediaURL ?? "")
            httpBodyString = httpBodyString.replacingOccurrences(of: Constants.HTTPBody.LatitudeToken, with: String(studentLocation.coordinate.latitude))
            httpBodyString = httpBodyString.replacingOccurrences(of: Constants.HTTPBody.LongitudeToken, with: String(studentLocation.coordinate.longitude))
            
            print("httpBodyString: \(httpBodyString)")
            
            request.httpBody = httpBodyString.data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    postNewCompletionHandler(false, error.localizedDescription)
                    return
                }
                
                // Check status code
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200, statusCode <= 299 else {
                    print("Unsuccesful resopnse code in postNewStudentLocation\n\(String(describing:response!))")
                    postNewCompletionHandler(false, "Unsuccessful status code in postNewStudentLocation")
                    return
                }
                
                // Check Data
                guard let data = data else {
                    postNewCompletionHandler(false, "No data returned in postNewStudentLocation")
                    return
                }
                
                
                // TODO: Make this work!
                // Parse results NOT from Udacity API. Do not remove first 5 characters.
                var parsedResult: AnyObject! = nil
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                }
                catch {
                    print("Could not parse data in sendNewStudentLocation")
                    postNewCompletionHandler(false, "Could not parse data in sendNewStudentLocation")
                    return
                }
                
                // Handle success
                if let parsedResult = parsedResult {
                    print("Result from post new student location:\n\(parsedResult)")
                    postNewCompletionHandler(true, nil)
                }
            }
            task.resume()
        }
        
    }
    
    func getUserInfo(userInfoCompletionHandler: @escaping(_ userInfoDict: Dictionary<String, Any>?, _ errorString: String?) -> Void) {
        
        guard let accountKey = UserDefaults.standard.object(forKey: Constants.UserDefaultsKey.AccountKey) as? String else {
            print("Account key not set in Client getUserInfo method")
            userInfoCompletionHandler(nil, "Something went wrong. Please logout and back in again")
            return
        }
        guard let url = URL(string: Constants.Url.UdacityUserHostAndPath + accountKey) else {
            print("URL init failed in getUserInfo()")
            userInfoCompletionHandler(nil, "Something went wrong. Please try again.")
            return
        }
        
        let request = URLRequest.init(url: url)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                userInfoCompletionHandler(nil, error.localizedDescription)
                return
            }
            
            // Check status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200, statusCode <= 299 else {
                print("Unsuccesful resopnse code in getUserInfo\n\(String(describing:response!))")
                userInfoCompletionHandler(nil, "Unsuccessful status code in getUserInfo()")
                return
            }
            
            // Check Data
            guard let data = data else {
                userInfoCompletionHandler(nil, "No data returned in getUserInfo")
                return
            }
            
            // Parse data
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (result, error) in
                
                if let error = error {
                    userInfoCompletionHandler(nil, error.localizedDescription)
                    return
                }
                // Handle success
                if let resultDict = result as? Dictionary<String, Any>, let userInfoDict = resultDict["user"] as? Dictionary<String, Any> {
                    print("Result from getUserInfo:")
                    print(userInfoDict)
                    userInfoCompletionHandler(userInfoDict, nil)
                }
                else {
                    print("Didn't get a dictionary back in getUserInfo")
                    userInfoCompletionHandler(nil, "Not a dictionary in getUserInfo")
                }
            })
            
        }
        dataTask.resume()
        
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
            
            if let latitude = location[Constants.StudentInformationKey.Latitude] as? Double,
                let longitude = location[Constants.StudentInformationKey.Longitude] as? Double,
                let firstName = location[Constants.StudentInformationKey.FirstName] as? String,
                let lastName = location[Constants.StudentInformationKey.LastName] as? String,
            let uniqueKey = location[Constants.StudentInformationKey.UniqueKey] as? String {
                
                let newLocation = OTMStudentInformation(createdAt: location[Constants.StudentInformationKey.CreatedAt] as! String,
                                                     updatedAt: location[Constants.StudentInformationKey.UpdatedAt]  as! String,
                                                     objectID: location[Constants.StudentInformationKey.ObjectID]  as! String,
                                                     firstName: firstName,
                                                     lastName: lastName,
                                                     latitude: latitude,
                                                     longitude: longitude,
                                                     mapString: location[Constants.StudentInformationKey.MapString] as? String,
                                                     mediaURL: location[Constants.StudentInformationKey.MediaURL] as? String,
                                                     uniqueKey: uniqueKey)
                
                tempArray.append(newLocation)
            }
        }
        
        print(tempArray.count)
        return tempArray
    }
    
    // Logout Facebook
    func logoutOfFacebook() {
        AccessToken.current = nil
        UserProfile.current = nil
    }
    
    func addSessionIDExpirationDateAndAccountKeyToUserDefaults(sessionID: String, expirationDate: String, acountKey: String) {
        UserDefaults.standard.set(sessionID, forKey: Constants.UserDefaultsKey.SessionID)
        UserDefaults.standard.set(expirationDate, forKey: Constants.UserDefaultsKey.SessionExpirationDate)
        UserDefaults.standard.set(accountKey, forKey: Constants.UserDefaultsKey.AccountKey)
    }
    
    // Delete session id from user defaults
    func removeSessionIDExpirationDateAndAccountKeyFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKey.SessionID)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKey.AccountKey)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKey.SessionExpirationDate)
    }
}





