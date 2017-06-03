import UIKit
import Dispatch

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
        
        AppDelegate.service.login { [unowned self] result in
            switch result {
            case .success():
                self.performSegue(withIdentifier: PKSegueIdentifiers.loggedIn.rawValue, sender: nil)
            case .error(let message):
                let alertController = UIAlertController(title: "無法登入", message: message ?? "沒有訊息", preferredStyle: .alert)
                let action = UIAlertAction(title: "瞭解", style: UIAlertActionStyle.default)
                alertController.addAction(action)
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true) { _ in
                        DispatchQueue.main.async(group: nil, qos: DispatchQoS.userInteractive, flags: [.enforceQoS]) {
                            self.activityIndicator.stopAnimating()
                            self.loginButton.isHidden = false
                        }
                    }
                }
            }
        }
    }
}
