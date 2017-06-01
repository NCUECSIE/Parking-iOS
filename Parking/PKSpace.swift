import Foundation
import CoreLocation

struct Fee {
    let unitTime: TimeInterval
    let charge: Double
}

struct PKSpace {
    var parked: Bool
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let _id: String
    
    let fee: Fee?
    let providerId: String?
    let markings: String?
}
