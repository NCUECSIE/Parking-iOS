import UIKit
import MapKit
import Dispatch

class PKMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var notice: UILabel!
    var cancelNoticeWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.showsUserLocation = true
        map.showsPointsOfInterest = true
        
        let testRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 24.06, longitude: 120.545),
                                            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        map.setRegion(testRegion, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "地圖"
    }
    
    func show(message: String) {
        if let lastWorkItem = cancelNoticeWorkItem {
            lastWorkItem.cancel()
        }
        
        notice.text = message
        let dismissed = DispatchTime.now() + 1.0
        
        cancelNoticeWorkItem = DispatchWorkItem { [unowned self] in
            self.notice.text = ""
        }
        DispatchQueue.main.asyncAfter(deadline: dismissed, execute: cancelNoticeWorkItem!)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let placemark as MKPlacemark:
            guard let space = placemark.addressDictionary?["space"] as? PKSpace else {
                let annotation = MKPinAnnotationView()
                annotation.pinTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                return annotation
            }
            
            let parked = space.parked
            let annotation = MKPinAnnotationView()
            if parked {
                annotation.pinTintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            } else {
                annotation.pinTintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            }
            
            return annotation
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        show(message: "載入資料中")
        
        AppDelegate.service.spaces(in: map.region) { [unowned self] result in
            switch result {
            case .error(let message):
                self.show(message: message ?? "-1")
            case .success(let result):
                self.show(message: "載入完成")
                
                self.map.removeAnnotations(self.map.annotations)
                self.map.addAnnotations(result.map { space -> MKAnnotation in
                    MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: space.latitude, longitude: space.longitude),
                                addressDictionary: [ "space": space ])
                })
            }
        }
    }
    
    var selectedSpace: PKSpace?
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        if case let placemark as MKPlacemark = annotation {
            selectedSpace = placemark.addressDictionary!["space"] as? PKSpace
            performSegue(withIdentifier: PKSegueIdentifiers.spaceDetail.rawValue, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PKSegueIdentifiers.spaceDetail.rawValue {
            let destination = segue.destination as! PKSpaceViewController
            destination.space = selectedSpace
            selectedSpace = nil
        }
    }
    
    @IBAction func reserve(segue: UIStoryboardSegue) {
        let _ = (segue.source as! PKSpaceViewController).space!
        let _ = self.tabBarController
    }
}
