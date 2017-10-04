import UIKit

class LoginViewController: UIViewController {
    
    var gradientView: GradientView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradientToView()
        addTapGestureToView()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Set placeholder texts attributes
        emailTextField.attributedPlaceholder = emailAttributedString()
        passwordTextField.attributedPlaceholder = passwordAttributedString()
    
    }
    
    @objc func resignAnyFirstResponder() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
    
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Placeholder attributed string methods
    func emailAttributedString() -> NSAttributedString {

        return NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
    }
    
    func passwordAttributedString() -> NSAttributedString {
        
        return NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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
}


