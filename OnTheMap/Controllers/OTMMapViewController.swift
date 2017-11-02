import UIKit
import MapKit

class OTMMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    
    var dataStore: OTMDataStore!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Set delegates
        mapView.delegate = self
        tabBarController?.delegate = self
        
        
        // TODO: Add indicator for call
        OTMClient.shared.getStudentLocationsInDateOrder { [unowned self] (success, arrayOfLocations, errorString) in
            
            // Check error
            DispatchQueue.main.async {
                if let error = errorString {
                    self.presentAlertWith(title: error, message: "")
                }
                else if success {
                    
                    if let studentLocations = arrayOfLocations {
                    
                        self.dataStore.studentLocations = studentLocations
                        self.reloadMapAnnotationsFromDataStore()
                    }
                }
                else {
                    self.presentAlertWith(title: "Unknown error", message: "")
                    print("Should never be here. Error in viewDidLoad()")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("In map view controller with \(dataStore.studentLocations.count) student locations")
    }

    
    // MARK: - Button methods
    @IBAction func logoutBarButtonTapped(_ sender: UIBarButtonItem) {
    
        OTMClient.shared.deleteUdacitySession { [unowned self] (success, errorString) in
            
            DispatchQueue.main.async {
                
                if let errorString = errorString {
                    self.presentAlertWith(title: errorString, message: "")
                }
                else if success {
                    
                    OTMClient.shared.logoutOfFacebook()
                    OTMClient.shared.removeSessionIDAndAccountKeyFromUserDefaults()
                    
                    self.navigationController?.tabBarController?.navigationController?.popToRootViewController(animated: true)
                }
                else {
                    self.presentAlertWith(title: "Unknown error", message: "")
                    print("Should never be here. Figure out what went wrong")
                }
            }
        }
    }
    
    @IBAction func refreshBarButtonTapped(_ sender: UIBarButtonItem) {
    
        getLocationDataWithUIEffectAndSpinner()
    }
    
    
    // MARK: - UI methods
    func deactivateUIForRefresh() {
        logoutButton.isEnabled = false
        refreshButton.isEnabled = false
        addLocationButton.isEnabled = false
        
        tabBarController?.tabBar.items?.first?.isEnabled = false
        tabBarController?.tabBar.items?.last?.isEnabled = false
    }
    
    func activateUI() {
        logoutButton.isEnabled = true
        refreshButton.isEnabled = true
        addLocationButton.isEnabled = true
    
        tabBarController?.tabBar.items?.first?.isEnabled = true
        tabBarController?.tabBar.items?.last?.isEnabled = true
    }
    
    // MARK: - Network data method
    func getLocationDataWithUIEffectAndSpinner() {
        
        deactivateUIForRefresh()
        
        dimScreenWithActivitySpinner()
        
        OTMClient.shared.getStudentLocationsInDateOrder { [unowned self] (success, locations, errorString) in
            
            DispatchQueue.main.async {
                if !success {
                    
                    self.undimScreenAndRemoveActivitySpinner()
                    self.activateUI()
        
                    self.presentAlertWith(title: errorString ?? "Error occured", message: "")
                }
                else {
                    print("Called for data in MAP view controller with \(locations!.count) locations")
                    
                    self.undimScreenAndRemoveActivitySpinner()
                    self.activateUI()
                    
                    // Handle new data
                    self.dataStore.studentLocations = locations
                    self.reloadMapAnnotationsFromDataStore()
                }
            }
        }
    }
    
    func reloadMapAnnotationsFromDataStore() {
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(self.dataStore.studentLocations)
    }
}


// MARK: - Map delegate methods
extension OTMMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        (view as! MKPinAnnotationView).pinTintColor = Constants.CustomColor.UdacityBlue
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        (view as! MKPinAnnotationView).pinTintColor = Constants.CustomColor.UdacityOrange
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("callout tapped")
        
        if let annotation = view.annotation {
            
            if var urlString = annotation.subtitle ?? nil { //Double unwrap subtitle String??
                
                if !urlString.starts(with: "http://") {
                    urlString = "http://" + urlString
                }
                
                if let url = URL(string: urlString) {
    
                    UIApplication.shared.open(url, options: [:])
                }
                else {
                
                    DispatchQueue.main.async { [unowned self] in
                        self.presentAlertWith(title: "Invalid link", message: "")
                    }
                }
            }
        }
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
            
            view.pinTintColor = Constants.CustomColor.UdacityOrange
            
            let button = UIButton.init(type: .custom)
            if let arrowImage = UIImage.init(named: "icon_forward-arrow") {
                button.setBackgroundImage(arrowImage, for: .normal)
            }
            button.frame = CGRect(x: 0, y: 0, width: view.frame.height, height:view.frame.height)
            view.rightCalloutAccessoryView = button
        }
        
        return view
    }
}


// MARK: - Tab bar controller delegate
extension OTMMapViewController: UITabBarControllerDelegate {
    
    // TODO: Do I even need this?
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // If same tab selected nothing to do.
        if viewController == tabBarController.selectedViewController {
            return true
        }
        
        // From view controller
        guard let selectedVC = (tabBarController.selectedViewController as! UINavigationController).viewControllers.first else {
            print("In tabBarController delegate: No passing FROM view controller.")
            return true
        }
        
        // To view controller
        guard let destinationVC = (viewController as! UINavigationController).viewControllers.first else {
            print("In tabBarController delegate: No passing TO view controller.")
            return true
        }
        
        
        if destinationVC.isKind(of: OTMMapViewController.self) {
            
            // Pass the Data store to map view controller
            (destinationVC as! OTMMapViewController).dataStore = (selectedVC as! OTMTableViewController).dataStore
        }
        else {
            
            // Pass the data store to the table view controller
            (destinationVC as! OTMTableViewController).dataStore = (selectedVC as! OTMMapViewController).dataStore
        }
        return true
    }
}

