import UIKit


class OTMTableViewController: UITableViewController {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    
    var dataStore: OTMDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Map view controller calls this first, but just in case call it here if needed.
        if dataStore.shouldCallForUdates {
            getLocationDataWithUIEffectAndSpinner()
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataStore.studentLocations!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.TableViewCell, for: indexPath) as! OTMTableViewCell

        let location = dataStore.studentLocations[indexPath.row]
        
        cell.nameLabel?.text = "\(location.firstName) \(location.lastName)"
        cell.mediaURLLabel?.text = location.mediaURL ?? ""

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = dataStore.studentLocations[indexPath.row]
        
        if var urlString = studentLocation.mediaURL, let url = URL(string:urlString) {
            
            if !urlString.starts(with: "http://") {
                urlString = "http://" + urlString
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: { [unowned self] (success) in
                
                if success {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                else {
                    // Could not open url
                    self.presentAlertWith(title: "Invalid link", message: "")
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            })
        }
        else {
            // No string or failed to create URL
            self.presentAlertWith(title: "Invalid link", message: "")
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        print(studentLocation.firstName)
        print(studentLocation.lastName)
    }
    
    
    // MARK: - Bar Button methods
    
    @IBAction func logoutBarButtonTapped(_ sender: UIBarButtonItem) {
        print("Logout button tapped")
        
        OTMClient.shared.deleteUdacitySession { [unowned self] (success, errorString) in
            
            DispatchQueue.main.async {
                
                if let errorString = errorString {
                    self.presentAlertWith(title: errorString, message: "")
                }
                
                else if success {
                    
                    OTMClient.shared.logoutOfFacebook()
                    OTMClient.shared.removeSessionIDExpirationDateAndAccountKeyFromUserDefaults()
                    
                    self.navigationController?.tabBarController?.navigationController?.popToRootViewController(animated: true)
                }
                else {
                    self.presentAlertWith(title: "Unknown error", message: "")
                    print("Should never be here. In logoutButton method of table view controller")
                }
            }
        }
    }

    
    @IBAction func refreshBarButtonTapped(_ sender: UIBarButtonItem) {
        
        getLocationDataWithUIEffectAndSpinner()
    }
    
    
    // MARK: - Data from network method
    
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
                    print("Just called for data. In table view controller with \(locations!.count) locations")
                    
                    self.undimScreenAndRemoveActivitySpinner()
                    self.activateUI()
               
                    // Handle new data
                    self.dataStore.shouldCallForUdates = false
                    self.dataStore.studentLocations = locations
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UI Methods
    
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

}


