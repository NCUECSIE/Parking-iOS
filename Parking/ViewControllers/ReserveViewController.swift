import UIKit
import MapKit
import CoreLocation

class ReserveViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var selectedGrid: CLLocationCoordinate2D? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Again, we put the user to a predefined region
        map.showsUserLocation = true
        map.showsPointsOfInterest = true
        
        let testRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 24.06, longitude: 120.545),
                                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        map.setRegion(testRegion, animated: false)
        
        // If a grid is already selected!
        selectedGrid?.normalize()
        
        if let selected = selectedGrid {
            map.add(selected.makeOverlay(), level: .aboveRoads)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(recognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        map.addGestureRecognizer(tapGestureRecognizer)
        
        datePicker.minimumDate = Date().addingTimeInterval(1800.0)
        
        reserveButton.isEnabled = (selectedGrid != nil)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
        renderer.alpha = 0.4
        renderer.fillColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return renderer
    }
    @IBAction func reserve() {
        reserveButton.isHidden = true
        navigationController?.navigationBar.backItem?.hidesBackButton = true
        
        let confirm = UIAlertController(title: "確認預約？", message: "您即將預約位於綠色區域內的車位。", preferredStyle: .alert)
        confirm.addAction(UIAlertAction(title: "取消", style: .cancel))
        confirm.addAction(UIAlertAction(title: "確認", style: .destructive) { action in
            self.activityIndicator.startAnimating()
            AppDelegate.service.makeReservation(in: self.selectedGrid!, on: self.datePicker.date) { result in
                var message = ""
                switch result {
                case .success(_):
                    message = "預約成功"
                case .error(_):
                    message = "預約失敗，可能是車位不足或是網路錯誤"
                }
                
                let alert = UIAlertController(title: "預約結果", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "瞭解", style: .cancel) {
                    _ in _ = self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        })
        
        present(confirm, animated: true)
    }
    func tap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: map)
        let point = map.convert(location, toCoordinateFrom: map)
        
        selectedGrid = point.normalized()
        map.removeOverlays(map.overlays)
        
        map.add(selectedGrid!.makeOverlay(), level: .aboveRoads)
        
        reserveButton.isEnabled = true
    }
}

fileprivate extension CLLocationCoordinate2D {
    func makeRect() -> [CLLocationCoordinate2D] {
        return [
            self,
            CLLocationCoordinate2D(latitude: latitude + 0.01, longitude: longitude),
            CLLocationCoordinate2D(latitude: latitude + 0.01, longitude: longitude + 0.01),
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude + 0.01),
            self
        ]
    }
    func makeOverlay() -> MKPolygon {
        let coordinates = makeRect()
        return MKPolygon(coordinates: coordinates, count: coordinates.count)
    }
}
