import UIKit

class LoginRequestViewController: UIViewController {
    @IBOutlet weak var loginDescription: UITextView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        activityIndicator.hidesWhenStopped = true
    }
    @IBAction func loginButtonAction(_ sender: UIButton) {
        activityIndicator.startAnimating()
        loginButton.isHidden = true
        
        AppDelegate.service.login { result in
            self.activityIndicator.stopAnimating()
            self.loginButton.isHidden = false
            switch result {
            case .success():
                self.performSegue(withIdentifier: PKSegueIdentifiers.loggedIn.rawValue, sender: nil)
            case .error(let message):
                print(message ?? "")
            }
        }
    }
}
