import UIKit
import MapKit
import Dispatch

class PKMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var notice: UILabel!
    var cancelNoticeWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "地圖"
        
        show(message: "地圖初始化！")
    }
    
    func show(message: String) {
        if let lastWorkItem = cancelNoticeWorkItem {
            lastWorkItem.cancel()
        }
        
        notice.text = message
        let dismissed = DispatchTime.now() + 5.0
        
        cancelNoticeWorkItem = DispatchWorkItem { [unowned self] in
            self.notice.text = ""
        }
        DispatchQueue.main.asyncAfter(deadline: dismissed, execute: cancelNoticeWorkItem!)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        <#code#>
    }
}
