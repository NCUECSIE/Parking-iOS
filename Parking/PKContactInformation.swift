import SwiftyJSON

struct PKContactInformation {
    var phone: String?
    var email: String?
    var address: String?
    
    init?(from object: JSON) {
        if !object.exists() {
            return nil
        }
        phone = object["phone"].string
        email = object["email"].string
        address = object["address"].string
    }
}

extension JSON {
    var pkcontactInformation: PKContactInformation? {
        return PKContactInformation(from: self)
    }
}
