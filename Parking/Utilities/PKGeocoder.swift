import CoreLocation

class PKGeocoder {
    static var shared: PKGeocoder = { return PKGeocoder() }()
    static var remote = 0 {
        didSet {
            print("\(PKGeocoder.remote) requests fetched from remote")
        }
    }
    
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
                print("An item is fetched by didSet")
                
                let cached = cache.first(where: { (item: CodingItem) -> Bool in item.coordinate.isNear(another: current!.coordinate) })
                if cached != nil {
                    print("the item is served from cache!")
                    current!.result = cached!.result!
                    fetchNext()
                } else {
                    print("the item is served by CLGeocoder!")
                    var item = current!
                    PKGeocoder.remote += 1
                    coder.reverseGeocodeLocation(current!.location) { result, error in
                        print("& the item was done serving by CLGeocoder!")
                        if result == nil || result!.count == 0 {
                            print("found nil...")
                            item.result = nil
                        } else {
                            let placemark = result![0]
                            item.result = placemark
                            self.cache.append(item)
                        }
                        self.fetchNext()
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
            print("item is requested, and is served by cache")
            
            completionHandler(cached!.result!)
            return -1
        }
        let item = CodingItem(coordinate, completionHandler: completionHandler)
        if current == nil {
            print("item is requested, and is served by CLGeocoder now")
            current = item
        } else {
            print("item is requested, and is added to queued")
            queue.append(item)
        }
        return item.index
    }
    func cancel(index: Int) {
        if current != nil && current!.index > index {
            print("An item that is served is cancelled, possibly logic error")
            return
        }
        if index == -1 {
            print("An item that is served from cache is cancelled, possibly logic error, check for -1 in return code")
            return
        }
        if current?.index == index {
            print("A current item is cancelled, will fetch anyway.")
            current!.cancelled = true
        } else {
            print("A queued item is cancelled, will remove from queue.")
            if let index = queue.index(where: { $0.index == index }) {
                queue.remove(at: index)
            }
        }
    }
    
    func fetchNext() {
        if self.queue.count > 0 {
            print("And another is now begin fetched into current")
            self.current = self.queue.removeFirst()
            print(self.current)
        } else {
            print("no items pending")
            self.current = nil
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
