import UIKit


class OTMDataStore: NSObject {

    var studentLocations: [OTMStudentInformation]!
    var shouldCallForUdates = true
    
    override init() {
        super.init()
        
        self.studentLocations = [OTMStudentInformation]()
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateLocations), name: Constants.CustomNotification.UpdateNotification.name, object: nil)
    }
    
    @objc func shouldUpdateLocations() {
        self.shouldCallForUdates = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

