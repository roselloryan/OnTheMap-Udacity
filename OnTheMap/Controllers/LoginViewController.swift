import UIKit
import FacebookLogin
import FacebookCore
import FacebookShare


class LoginViewController: UIViewController {
    
    var gradientView: GradientView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    weak var facebookLoginButton: LoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradientToView()
        addTapGestureToView()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Set placeholder texts attributes
        emailTextField.attributedPlaceholder = emailAttributedString()
        passwordTextField.attributedPlaceholder = passwordAttributedString()
        
        addFacebookLoginButtonWithConstraints()
        
        setAttributesForSignUpButton()
        
        navigationController?.navigationBar.isHidden = true
        
    
        // Check if user has logged in and if session has not exired
        if UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.SessionID) != nil {
            
            if var dateString = UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.SessionExpirationDate) {
                
                // Remove partial seconds for ISO8601 formatter to return Swift Date
                dateString.removeSubrange((dateString.index(dateString.endIndex, offsetBy: -8))...dateString.index(dateString.endIndex, offsetBy: -2))
                
                let dateFormatter = ISO8601DateFormatter()
                
                if let  swiftExpirationDate = dateFormatter.date(from: dateString) {
                
                    if swiftExpirationDate > Date() {
                        
                        performSegue(withIdentifier: Constants.Identifier.MainSegue, sender: self)
                    }
                    else {
                        presentAlertWith(title: "Session has expired", message: "Please login")
                        print("session expired. Login required.")
                    }
                }
            }
        }
        else {
            checkForFacebookAccessTokenAndLoginIfFound()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func resignAnyFirstResponder() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    // MARK: - Button Methods
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty  else {
            
            presentAlertWith(title: "Email and password required to login", message: "")
            return
        }
        
        dimScreenWithActivitySpinner()
        resignAnyFirstResponder()
        
        OTMClient.shared.getSessionIDWith(email: email, password: password) { [unowned self] (success, errorString) in
            
            DispatchQueue.main.async {
                
                self.undimScreenAndRemoveActivitySpinner()
            
                if success {
                
                    self.performSegue(withIdentifier: Constants.Identifier.MainSegue, sender: self)
                    self.clearBothTextFields()
                    self.resignAnyFirstResponder()
                }
                else {
                
                    self.presentAlertWith(title: errorString ?? "unknown error occured", message: "")
                    print("Error in loginButtonTapped getIDWithEmailPassword: \(errorString!)")
                }
            }
        }
    }
    

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        if let url = URL(string: Constants.Url.SignUpUrlString) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: { [unowned self] (success) in
                if !success {
                    print("url failed in sign up button")
                    self.presentAlertWith(title: "Could not open page", message: "")
                }
            })
        }
    }
    
    
    // MARK: Placeholder attributed string methods
    func emailAttributedString() -> NSAttributedString {
        return NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
    }
    
    func passwordAttributedString() -> NSAttributedString {
        return NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
    }
    
    func setAttributesForSignUpButton() {
        
        let title = signUpButton.titleLabel?.text ?? "Don't have an account? Sign up"
        
        let signUpAttributedString = NSMutableAttributedString.init(string: title, attributes: nil)
        
        let signUpRange = (title as NSString).range(of: "Sign up")
        signUpAttributedString.setAttributes([NSAttributedStringKey.foregroundColor: Constants.CustomColor.UdacityBlue], range: signUpRange)
        
        signUpButton.setAttributedTitle(signUpAttributedString, for: .normal)
    }
    
    
    // MARK: Gradient method
    func addGradientToView() {
        
        gradientView = GradientView.init(frame: view.bounds)
        view.insertSubview(gradientView, at: 0)
    }
    
    // MARK: Tap Gesture Method
    func addTapGestureToView() {
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(resignAnyFirstResponder))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Create data store without singleton
        let destinationTBVC = segue.destination as! UITabBarController
        
        let mapNav = destinationTBVC.viewControllers?.first as! UINavigationController
        let tableNav = destinationTBVC.viewControllers?.last as! UINavigationController
        
        let mapVC = mapNav.viewControllers.first as! OTMMapViewController
        let tableviewVC = tableNav.viewControllers.first as! OTMTableViewController
        
        tableviewVC.dataStore = OTMDataStore()
        mapVC.dataStore = tableviewVC.dataStore
    }
}


// MARK: Text Field Delegate and methods
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.attributedPlaceholder = nil
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField.text == "" {
            textField.attributedPlaceholder = textField == emailTextField ? emailAttributedString() : passwordAttributedString()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func clearBothTextFields() {
        // TODO: Reset with placeholders didEndEditing not called for both text fields
        emailTextField.text = String()
        passwordTextField.text = String()
        
        // Set placeholder texts attributes
        emailTextField.attributedPlaceholder = emailAttributedString()
        passwordTextField.attributedPlaceholder = passwordAttributedString()
        
    }
}


extension LoginViewController: LoginButtonDelegate {
    /**
     Called when the button was used to login and the process finished.
     - parameter loginButton: Button that was used to login.
     - parameter result:      The result of the login.
     */
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        print("\nResult from facebook login: \(result)")
        
        if let accessToken = AccessToken.current {
            
            OTMClient.shared.getSessionIDWithFacebookAccessToken(accessToken.authenticationToken, completionHandler: { [unowned self] (success, errorString) in
                
                DispatchQueue.main.async {
                    
                    if success {
                        self.performSegue(withIdentifier: Constants.Identifier.MainSegue, sender: self)
                        self.clearBothTextFields()
                        self.resignAnyFirstResponder()
                    }
                    else if let error = errorString {
                        self.presentAlertWith(title: error, message: "")
                    }
                }
            })
        }
    }
    
    /**
     Called when the button was used to logout.
     - parameter loginButton: Button that was used to logout.
     */
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        // TODO: Delete session on logout check facebook logout proceedures
        print("\nAnything to clean up on log out?\n")
    }
    
    // Facebook button method
    func addFacebookLoginButtonWithConstraints() {
        let facebookButton = LoginButton.init(frame: loginButton.frame, readPermissions: [  .publicProfile])
        facebookLoginButton = facebookButton
        facebookLoginButton.delegate = self
        view.addSubview(facebookLoginButton)
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Constraints
        facebookButton.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
        facebookButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20).isActive =
        true
        facebookButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive =
        true
        facebookButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    func checkForFacebookAccessTokenAndLoginIfFound() {
        // TODO: Other possibly status of token, expired, revoked what happens?
        
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            print("User logged in. Go ahead past login controller")
            print("userID: \(accessToken.userId!)")
            print("authentication token: \(accessToken.authenticationToken)")
            
            OTMClient.shared.getSessionIDWithFacebookAccessToken(accessToken.authenticationToken, completionHandler: { [unowned self] (success, errorString) in
                
                DispatchQueue.main.async {
                    
                    if success {
                        self.performSegue(withIdentifier: Constants.Identifier.MainSegue, sender: self)
                    }
                    else if let error = errorString {
                        self.presentAlertWith(title: error, message: "")
                    }
                }
            })
        }
    }
    
}
