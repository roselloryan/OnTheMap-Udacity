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
        
        navigationController?.navigationBar.isHidden = false
    
        mapView.delegate = self
        
        // TODO: Put this in the view controller that is first selected upon launch
        tabBarController?.delegate = self
        
        
        
        OTMClient.shared.getStudentLocationsInDateOrder { [unowned self] (success, arrayOfLocations, errorString) in
            
            // Check error
            if let error = errorString {
                self.presentAlertWith(title: error, message: "")
            }
                
            else if success {
                if let studentLocations = arrayOfLocations {
                    self.dataStore.studentLocations = studentLocations
                    
                    DispatchQueue.main.async {
                        self.reloadMapAnnotationsFromDataStore()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("In map view controller with \(dataStore.studentLocations.count) student locations")
    }

    
    // MARK: - Button methods
    @IBAction func logoutBarButtonTapped(_ sender: UIBarButtonItem) {
    
        OTMClient.shared.deleteUdacitySession { [unowned self] (success, errorString) in
            
            if let errorString = errorString {
                self.presentAlertWith(title: errorString, message: "")
            }
            else if success {
                // TODO: Delete session id from userDefaults
                DispatchQueue.main.async {
                    self.navigationController?.tabBarController?.navigationController?.popToRootViewController(animated: true)
                }
            }
            else {
                self.presentAlertWith(title: "Unknown error", message: "")
                print("Should never be here. Figure out what went wrong")
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
        
        // Add dimmed view
        let dimmedView = UIView(frame: view.window!.frame)
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.window?.addSubview(dimmedView)
        
        // Add activity indicator
        let spinnerView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinnerView.center = CGPoint(x: view.center.x, y: view.center.y - navigationController!.navigationBar.frame.height)
        view.window?.addSubview(spinnerView)
        spinnerView.startAnimating()
        
        
        OTMClient.shared.getStudentLocationsInDateOrder { [unowned self] (success, locations, errorString) in
            
            if !success {
                
                DispatchQueue.main.async {
                    // Remove activity indicator
                    spinnerView.stopAnimating()
                    spinnerView.removeFromSuperview()
                    
                    // Remove dimmed view
                    dimmedView.removeFromSuperview()
                    
                    self.activateUI()
        
                    self.presentAlertWith(title: errorString ?? "Error occured", message: "")
                }
            }
            else {
                DispatchQueue.main.async {
                    
                    // Remove activity indicator
                    spinnerView.stopAnimating()
                    spinnerView.removeFromSuperview()
                    
                    // Remove dimmed view
                    dimmedView.removeFromSuperview()
                    
                    self.activateUI()
                    
                    // Handle new data
                    print("In MAP view controller with \(locations!.count) locations")
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


extension OTMMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("MKAnnotationView selected")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("callout tapped")
        
        if let annotation = view.annotation {
            if let urlString = annotation.subtitle ?? nil { //Double unwrap subtitle String??
                if let url = URL(string: urlString) {
                    print("We have a url... omg")
                    UIApplication.shared.open(url, options: [:])
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
            
            let button = UIButton(type: .detailDisclosure)
            button.frame = CGRect.zero
            view.rightCalloutAccessoryView = button
            
            let spacerView = UIView()
            spacerView.frame = CGRect.zero
            view.leftCalloutAccessoryView = spacerView
        }
        
        return view
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("does this get called when selecting tab view controllers?")
        
    }
}


extension OTMMapViewController: UITabBarControllerDelegate {
    
    // TODO: Do I even need this?
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // From view controller
        guard let selectedVC = (tabBarController.selectedViewController as! UINavigationController).viewControllers.first else {
            print("In table view delegate: Not passing FROM a view controller.")
            return true
        }
        print(selectedVC.self)
        
        // To view controller
        guard let destinationVC = (viewController as! UINavigationController).viewControllers.first else {
            print("In table view delegate: Not a view controller to pass the data store to.")
            return true
        }
        print(destinationVC.self)
        
        
        if destinationVC.isKind(of: OTMMapViewController.self) {
            // Pass the Data store to map view controller
            print("Pass the Data store to map view controller")
            (destinationVC as! OTMMapViewController).dataStore = (selectedVC as! OTMTableViewController).dataStore
        }
        else {
            // Pass the data store to the table view controller
            print("Pass the Data store to table view controller")
            (destinationVC as! OTMTableViewController).dataStore = (selectedVC as! OTMMapViewController).dataStore
        }
        return true
    }
}

