import UIKit
import MapKit

class PKSpaceViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var markings: UILabel!
    
    var space: PKSpace!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "車位資訊"
    }
    override func viewDidLoad() {
        // 1. 將地圖移動到正確位置
        let coordinate = space.location
        map.addAnnotation(MKPlacemark(coordinate: coordinate))
        map.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001)), animated: false)
        
        // 2. 載入車位資料
        AppDelegate.service.space(id: space._id) { space in
            switch space {
            case .error(_):
                let alertController = UIAlertController(title: "載入錯誤", message: "未知的錯誤", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "回地圖", style: .cancel) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alertController, animated: true)
            case .success(let space):
                let dateComponentsFormatter = DateComponentsFormatter()
                dateComponentsFormatter.unitsStyle = .full
                let currencyFormatter = NumberFormatter()
                currencyFormatter.numberStyle = .currency
                
                let dateString = "\(dateComponentsFormatter.string(from: space.fee!.unitTime)!)"
                let currencyString = "\(currencyFormatter.string(from: NSNumber(value: space.fee!.charge))!)"
                
                self.providerName.text = "\(space.provider!.name)"
                self.fee.text = "每 \(dateString) \(currencyString)"
                self.markings.text = space.markings!
            }
        }
    }
}
