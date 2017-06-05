import SwiftyJSON

enum PKProviderType: String {
    case government = "government"
    case `private`  = "private"
    
    init?(from value: JSON) {
        self.init(rawValue: value.stringValue)
    }
}
