import UIKit
import MapKit
import CoreLocation

class ReservationViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var markingsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancellingIndicator: UIActivityIndicatorView!
    
    var reservation: PKReservation!
    var placemark: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 將地圖移動到正確位置
        let coordinate = reservation.space.location
        map.addAnnotation(MKPlacemark(coordinate: coordinate))
        map.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.0025, longitudeDelta: 0.0025)), animated: false)
        
        // 2. 產生子字串
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .full
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        let timeFormatter = DateFormatter()
        timeFormatter.doesRelativeDateFormatting = true
        timeFormatter.locale = Locale.current
        timeFormatter.timeStyle = .medium
        timeFormatter.dateStyle = .medium
        
        let dateString = dateComponentsFormatter.string(from: reservation.space.fee!.unitTime)!
        let currencyString = currencyFormatter.string(from: NSNumber(value: reservation.space.fee!.charge))!
        let timeString = timeFormatter.string(from: reservation!.begin)
        
        // 3. 顯示資訊到其他 Label
        providerNameLabel.text = reservation.space.provider!.name
        feeLabel.text = "每 \(dateString) \(currencyString)"
        markingsLabel.text = reservation.space.markings!
        timeLabel.text = timeString
        
        if let placemark = placemark {
            locationLabel.text = "\(placemark.subLocality ?? placemark.locality ?? "")\(placemark.thoroughfare ?? "")\(placemark.subThoroughfare ?? "")"
        } else {
            locationLabel.text = "無法取得地址"
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = "預約資訊"
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    @IBAction func cancel() {
        cancelButton.isEnabled = false
        cancellingIndicator.startAnimating()
        self.navigationController?.navigationItem.hidesBackButton = true
        
        let alertController = UIAlertController(title: "是否取消？", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "否", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(UIAlertAction(title: "是", style: .destructive) { _ in
            AppDelegate.service.cancel(self.reservation!) { result in
                var message = ""
                switch result {
                case .success(_):
                    message = "取消成功"
                case .error(_):
                    message = "取消失敗，請重試"
                }
                
                let resultAlert = UIAlertController(title: "取消結果", message: message, preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "瞭解", style: .cancel) { _ in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                
                self.present(resultAlert, animated: true)
            }
        })
        
        present(alertController, animated: true)
    }
    @IBAction func openInMap() {
        let regionDistance = 2000.0
        let coordinates = reservation.space.location
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = reservation.space.markings!
        
        mapItem.openInMaps(launchOptions: options)
    }
}
