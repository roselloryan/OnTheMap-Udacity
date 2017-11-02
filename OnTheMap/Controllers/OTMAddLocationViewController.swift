import UIKit
import MapKit

class OTMAddLocationViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlLinkTextField: UITextField!
    
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var localSearchResponse: MKLocalSearchResponse!
    
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    // MARK: - Button methods
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func findLocationTapped(_ sender: UIButton) {
        print("Find location button tapped")
        
        //TODO: add alert for empty fields
        //TODO: check for valid url
        
        
        if !locationTextField.text!.isEmpty, let searchString = locationTextField.text {
            
            // Create local search request object
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = searchString
            
            // Create Local Search object
            let localSearch = MKLocalSearch.init(request: searchRequest)
            
            // Update UI for network call
            dimScreenWithActivitySpinner()
            deactivateUI()
            
            // Start local search
            localSearch.start(completionHandler: { [unowned self] (result, error) in
                
                DispatchQueue.main.async {
                    
                    // Update UI for return
                    self.undimScreenAndRemoveActivitySpinner()
                    self.activateUI()
                    
                    if let error = error {
                        // TODO: Handle error
                        print(error.localizedDescription)
                        self.presentAlertWith(title: error.localizedDescription, message: "")
                    }
                    else if let result = result {
                        
                        // TODO: Handle result
                        // Narrow results. Possibly in table view
                        // Present map view with pin from result
                        
                        print(result)
                        
                        self.localSearchResponse = result
                        self.performSegue(withIdentifier: Constants.Identifier.addLocationMapSeque, sender: self)
                    }
                }
            })
        }
    }
    
    // MARK: - UI methods
    func deactivateUI() {
        cancelButton.isEnabled = false
        findLocationButton.isEnabled = false
        locationTextField.isEnabled = false
        urlLinkTextField.isEnabled = false
    }
    
    func activateUI() {
        cancelButton.isEnabled = true
        findLocationButton.isEnabled = true
        locationTextField.isEnabled = true
        urlLinkTextField.isEnabled = true
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Pass the local search response to AddLocationMapViewController
        let destinationVC = segue.destination as! OTMAddLocationMapViewController
        destinationVC.mediaURLString = urlLinkTextField.text ?? ""
        destinationVC.localSearchResponse = localSearchResponse
    }

}
