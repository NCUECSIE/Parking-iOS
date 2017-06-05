import UIKit

class InternalSettingsViewController: UIViewController {
    @IBOutlet weak var tokenField: UITextField!
    
    @IBAction func saveToken() {
        _ = PKKeychain.set(key: "pkserver", value: tokenField.text ?? "")
        exit(0)
    }
}
