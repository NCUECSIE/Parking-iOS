import Foundation
import SwiftyJSON

struct PKParking {
    let _id: String
    let plate: String
    let begin: Date
    let space: PKSpace
    
    init?(from object: JSON) {
        guard let __id = object["_id"].string,
            let _plate = object["plate"].string,
            let _begin = object["begin"].date,
            let _space = object["space"].pkspace else {
                return nil
        }
        
        _id = __id
        plate = _plate
        begin = _begin
        space = _space
    }
}

extension JSON {
    var pkparking: PKParking? {
        return PKParking(from: self)
    }
}
