import UIKit

class InternalSettingsViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        tokenField.text = AppDelegate.service.token
    }
    @IBOutlet weak var tokenField: UITextField!
    
    @IBAction func saveToken() {
        _ = PKKeychain.set(key: "pkserver", value: tokenField.text ?? "")
        exit(0)
    }
}
