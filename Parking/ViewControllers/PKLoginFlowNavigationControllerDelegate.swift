import UIKit

class PKLoginFlowNavigationControllerDelegate: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !AppDelegate.service.loggedIn {
            self.performSegue(withIdentifier: PKSegueIdentifiers.loginRequest.rawValue, sender: nil)
        } else {
            self.performSegue(withIdentifier: PKSegueIdentifiers.mainView.rawValue, sender: nil)
        }
    }
    
    @IBAction func loggedIn(segue: UIStoryboardSegue) {
        performSegue(withIdentifier: PKSegueIdentifiers.mainView.rawValue, sender: nil)
        setViewControllers([viewControllers[1]], animated: true)
    }
}
