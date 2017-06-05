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
        let cached = cache.first(where: { (item: CodingItem) -> Bool in item.coordinate.isNear(another: coordinate) })
        if cached != nil {
            print("returned from cache")
            completionHandler(cached!.result!)
            return -1
        }
        
        let item = CodingItem(coordinate, completionHandler: completionHandler)
        if current == nil {
            current = item
        } else {
            queue.append(item)
        }
        return item.index
    }
    func cancel(index: Int) {
        if current != nil && current!.index > index {
            return
        }
        if index == -1 {
            return
        }
        
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

extension CLLocationCoordinate2D {
    func isNear(another: CLLocationCoordinate2D) -> Bool {
        let delta1 = abs(latitude - another.latitude)
        let delta2 = abs(longitude - another.longitude)
        if delta1 < Double.leastNonzeroMagnitude && delta2 < Double.leastNonzeroMagnitude {
            return true
        } else {
            return false
        }
    }
}
