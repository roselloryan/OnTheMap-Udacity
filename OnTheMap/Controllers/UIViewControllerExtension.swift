import Foundation
import UIKit

extension UIViewController {
    
    func presentAlertWith(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    func dimScreenWithActivitySpinner() {
        
        // Add dimmed view
        let dimmedView = UIView(frame: view.window!.frame)
        dimmedView.tag = 1
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.window?.addSubview(dimmedView)
        
        // Add activity indicator
        let spinnerView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinnerView.tag = 1
        spinnerView.center = CGPoint(x: view.center.x, y: view.center.y - navigationController!.navigationBar.frame.height)
        view.window?.addSubview(spinnerView)
        spinnerView.startAnimating()
    }
    
    func undimScreenAndRemoveActivitySpinner() {
        
        if let window = view.window {
            
            for view in window.subviews {
               
                if view.tag == 1 {
            
                    view.removeFromSuperview()
                }
            }
        }
    }
    
}
