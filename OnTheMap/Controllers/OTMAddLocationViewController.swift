import UIKit
import MapKit

class OTMAddLocationViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlLinkTextField: UITextField!
    
    var localSearchResponse: MKLocalSearchResponse!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func findLocationTapped(_ sender: UIButton) {
        print("Find location button tapped")
        
        if !locationTextField.text!.isEmpty, let searchString = locationTextField.text {
            
            // Create local search request object
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = searchString
            
            // Create Local Search object
            let localSearch = MKLocalSearch.init(request: searchRequest)
            
            // TODO: Show activity indicator
            
            // Start local search
            localSearch.start(completionHandler: { [unowned self] (result, error) in
                
                if let error = error {
                    // TODO: Handle error
                    print(error.localizedDescription)
                }
                else if let result = result {
                    // TODO: Handle result
                    // Narrow results. Possibly in table view
                    // Present map view with pin from result
                    print(result)
                    self.localSearchResponse = result
                    self.performSegue(withIdentifier: Constants.Identifier.addLocationMapSeque, sender: self)
                }
            })
        }
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationVC = segue.destination as! OTMAddLocationMapViewController
        destinationVC.mediaURLString = urlLinkTextField.text ?? ""
        destinationVC.localSearchResponse = localSearchResponse
    }

}
