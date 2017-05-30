import Foundation
import Alamofire
import Accounts
import SwiftyJSON

class PKService {
    var loggedIn: Bool {
        return token != nil
    }
    
    lazy var config: [String: Any] = {
        let path = Bundle.main.path(forResource: "config", ofType: "plist")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let dictionary = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
        
        return dictionary
    }()
    lazy var rootEndpoint: URL = {
        return URL(string: self.config["endpoint"] as! String)!
    }()
    lazy var appId: String = {
        let value = self.config["facebookAppId"]! as! String
        return value
    }()
    
    var token: String? {
        return PKKeychain.get(key: "pkserver")
    }
    
    func login(completionHandler: @escaping (_ result: Result<Void>) -> Void) {
        let store = ACAccountStore()
        let facebook = store.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
        
        store.requestAccessToAccounts(with: facebook, options: [ACFacebookAppIdKey: appId, ACFacebookPermissionsKey: []], completion: { granted, error in
            if let error = error {
                completionHandler(.error(error.localizedDescription))
            } else if granted {
                if let accounts = store.accounts(with: facebook) as? [ACAccount] {
                    if accounts.count > 0 {
                        let facebookAccount = accounts[0]
                        let token = facebookAccount.credential.oauthToken
                        
                        // PKServer
                        let url = URL(string: "auth/facebook", relativeTo: self.rootEndpoint)!
                        var request = try! URLRequest(url: url, method: .post)
                        let json = [ "scope": "standard", "accessToken": token ] as JSON
                        request.httpBody = try! json.rawData()
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        Alamofire.request(request).responseString(queue: nil) { data in
                            if let _ = data.error {
                                completionHandler(.error("PKServer 錯誤"))
                            } else if let data = data.result.value {
                                _ = PKKeychain.set(key: "pkserver", value: data)
                                completionHandler(.success())
                            }
                        }
                    }
                }
            } else {
                completionHandler(.error("fatal"))
            }
        })
    }
}
