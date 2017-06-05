import CoreLocation

class PKGeocoder {
    static var shared: PKGeocoder = { return PKGeocoder() }()
    
    struct CodingItem {
        static var index = 0
        
        let coordinate: CLLocationCoordinate2D
        let completionHandler: (CLPlacemark?) -> Void
        let index: Int
        var cancelled: Bool
        var completed: Bool
        
        var result: CLPlacemark? {
            didSet {
                if !self.cancelled {
                    completionHandler(result)
                }
                self.completed = true
            }
        }
        
        
        var location: CLLocation {
            return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        
        init(_ coordinate: CLLocationCoordinate2D, completionHandler: @escaping (CLPlacemark?) -> Void) {
            self.index = CodingItem.index
            CodingItem.index += 1
            
            self.coordinate = coordinate
            self.completionHandler = completionHandler
            
            cancelled = false
            completed = false
            result = nil
        }
    }
    
    private let coder: CLGeocoder = { return CLGeocoder() }()
    private var current: CodingItem? = nil {
        didSet {
            if current != nil {
                var item = current!
                coder.reverseGeocodeLocation(current!.location) { result, error in
                    if result == nil || result!.count == 0 {
                        item.result = nil
                    } else {
                        let placemark = result![0]
                        item.result = placemark
                        
                        // Save the result to cache!
                        self.cache.append(item)
                    }
                    
                    if self.queue.count > 0 {
                        self.current = self.queue.removeFirst()
                    }
                }
            }
        }
    }
    private var queue: [CodingItem] = []
    private var cache: [CodingItem] = []
    
    func code(_ coordinate: CLLocationCoordinate2D, completionHandler: @escaping (CLPlacemark?) -> Void) -> Int {
        let item = CodingItem(coordinate, completionHandler: completionHandler)
        if current == nil {
            current = item
        } else {
            queue.append(item)
        }
        return item.index
    }
    func cancel(index: Int) {
        if current?.index == index {
            current!.cancelled = true
        } else {
            if let index = queue.index(where: { $0.index == index }) {
                queue.remove(at: index)
            }
        }
    }
    init() {}
}
