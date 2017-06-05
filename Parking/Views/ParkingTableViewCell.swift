import UIKit
import CoreLocation

class ParkingTableViewCell: UITableViewCell {
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var beginLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    var codingId: Int? = nil
    var parking: PKParking! {
        didSet {
            if let codingId = codingId {
                PKGeocoder.shared.cancel(index: codingId)
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
            
            let durationFormatter = DateComponentsFormatter()
            durationFormatter.unitsStyle = .full
            
            plateLabel.text = parking.plate
            addressLabel.text = "計算中..."
            beginLabel.text = dateFormatter.string(from: parking.begin)
            durationLabel.text = durationFormatter.string(from: Date().timeIntervalSince(parking.begin))
            
            codingId = PKGeocoder.shared.code(parking.space.location) { result in
                self.placemark = result
            }
        }
    }
    var placemark: CLPlacemark? {
        didSet {
            if let result = placemark {
                if let city = result.subLocality {
                    if let street = result.thoroughfare {
                        addressLabel.text = city + " " + street
                    } else {
                        addressLabel.text = city
                    }
                } else {
                    addressLabel.text = result.locality ?? result.country ?? "無法取得區域名稱"
                }
            } else {
                addressLabel.text = "無法取得區域名稱"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
