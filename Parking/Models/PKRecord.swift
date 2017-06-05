import SwiftyJSON

struct PKRecord {
    let _id: String
    let plate: String
    let end: Date
    let begin: Date
    let paid: Bool
    let charge: Int
    let space: PKSpace
    
    init?(from object: JSON) {
        guard let __id = object["_id"].string,
            let _plate = object["plate"].string,
            let _end = object["end"].date,
            let _begin = object["begin"].date,
            let _paid = object["paid"].bool,
            let _charge = object["charge"].int,
            let _space = object["space"].pkspace else {
                return nil
        }
        
        _id = __id
        plate = _plate
        end = _end
        begin = _begin
        paid = _paid
        charge = _charge
        space = _space
    }
}

extension JSON {
    var pkrecord: PKRecord? {
        return PKRecord(from: self)
    }
}
