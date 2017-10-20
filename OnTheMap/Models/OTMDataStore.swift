import UIKit


class OTMDataStore: NSObject {

    var studentLocations: [OTMStudentInformation]!

    override init() {
        self.studentLocations = [OTMStudentInformation]()
    }
}
