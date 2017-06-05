//
//  RecordTableViewCell.swift
//  Parking
//
//  Created by 徐鵬鈞 on 2017/6/5.
//
//

import UIKit
import CoreLocation

class RecordTableViewCell: UITableViewCell {
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeAndDurationLabel: UILabel!
    @IBOutlet weak var chargeLabel: UILabel!
    
    var codingId: Int? = nil
    var record: PKRecord! {
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
            
            let timeString = dateFormatter.string(from: record.begin)
            let durationString = durationFormatter.string(from: record.end.timeIntervalSince(record.begin))!
            
            plateLabel.text = record.plate
            addressLabel.text = "計算中..."
            timeAndDurationLabel.text = "\(timeString)｜\(durationString)"
            chargeLabel.text = "\(record.charge) 元新台幣"
            
            codingId = PKGeocoder.shared.code(record.space.location) { result in
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
}
