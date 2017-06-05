import CoreLocation
import SwiftyJSON

extension CLLocationCoordinate2D {
    mutating func normalize() {
        self = normalized()
    }
    func normalized() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: floor(latitude * 100.0) / 100.0,
            longitude: floor(longitude * 100.0) / 100.0
        )
    }
    var spec: String {
        let standard = normalized()
        return String(format: "%.2f:%.2f", arguments: [standard.latitude, standard.longitude])
    }
}

extension JSON {
    var date: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: stringValue)
    }
}
