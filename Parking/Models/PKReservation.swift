import SwiftyJSON

struct PKReservation {
    let _id: String
    let space: PKSpace
    let begin: Date
    
    init?(from object: JSON) {
        guard let __id = object["_id"].string,
              let _space = object["space"].pkspace,
              let _begin = object["begin"].date else {
                return nil
        }
        
        _id = __id
        space = _space
        begin = _begin
    }
}

extension JSON {
    var pkreservation: PKReservation? {
        return PKReservation(from: self)
    }
}
