import Foundation
import SwiftyJSON
import CoreLocation

struct Fee {
    let unitTime: TimeInterval
    let charge: Double
    
    init?(from object: JSON) {
        guard let _unitTime = object["unitTime"].double,
              let _charge = object["charge"].double else {
                return nil
        }
        unitTime = _unitTime
        charge = _charge
    }
}

struct PKSpace {
    var parked: Bool
    let location: CLLocationCoordinate2D
    let _id: String
    
    let fee: Fee?
    let provider: PKProvider?
    let markings: String?
    
    init?(from object: JSON) {
        guard let __id = object["_id"].string,
              let _parked = object["parked"].bool,
              let latitude = object["location"]["latitude"].double,
              let longitude = object["location"]["longitude"].double else {
                return nil
        }
        _id = __id
        parked = _parked
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        fee = object["fee"].fee
        provider = object["provider"].pkprovider
        markings = object["markings"].string
    }
}

extension JSON {
    var fee: Fee? {
        return Fee(from: self)
    }
    var pkspace: PKSpace? {
        return PKSpace(from: self)
    }
}
