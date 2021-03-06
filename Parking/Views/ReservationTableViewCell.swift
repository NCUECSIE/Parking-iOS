import MapKit
import UIKit

@IBDesignable class ReservationTableViewCell: UITableViewCell {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    
    var codingId: Int? = nil
    var reservation: PKReservation! = nil {
        didSet {
            if let codingId = codingId {
                PKGeocoder.shared.cancel(index: codingId)
            }
            
            let timeFormatter = DateFormatter()
            timeFormatter.doesRelativeDateFormatting = true
            timeFormatter.locale = Locale.current
            timeFormatter.timeStyle = .medium
            timeFormatter.dateStyle = .medium
            
            timeLable.text = timeFormatter.string(from: reservation!.begin)
            locationLabel.text = "計算位置中..."
            
            codingId = PKGeocoder.shared.code(reservation.space.location) { result in
                self.placemark = result
                self.codingId = nil
            }
            if codingId == -1 {
                self.codingId = nil
            }
        }
    }
    var placemark: CLPlacemark? = nil {
        didSet {
            if let result = placemark {
                if let city = result.subLocality {
                    if let street = result.thoroughfare {
                        locationLabel.text = city + " " + street
                    } else {
                        locationLabel.text = city
                    }
                } else {
                    locationLabel.text = result.locality ?? result.country ?? "無法取得區域名稱"
                }
            } else {
                locationLabel.text = "無法取得區域名稱"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
