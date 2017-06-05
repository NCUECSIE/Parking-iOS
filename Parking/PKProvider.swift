import SwiftyJSON

struct PKProvider {
    let _id: String
    let type: PKProviderType
    let name: String
    let contactInformation: PKContactInformation?
    
    init?(from object: JSON) {
        guard let __id = object["_id"].string,
              let _type = PKProviderType(from: object["type"]),
              let _name = object["name"].string else {
                return nil
        }
        _id = __id
        type = _type
        name = _name
        contactInformation = object["contactInformation"].pkcontactInformation
    }
}

extension JSON {
    var pkprovider: PKProvider? {
        return PKProvider(from: self)
    }
}
