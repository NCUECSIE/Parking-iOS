import UIKit
import CoreLocation

class ParkingTableViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadParkings), for: .valueChanged)
        return control
    }()
    lazy var geocoder: CLGeocoder = {
        return CLGeocoder()
    }()
    var parkings: [PKParking] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkings.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let parking = parkings[indexPath.row]
        let location = CLLocation(latitude: parking.space.location.latitude, longitude: parking.space.location.longitude)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingCell") as? ParkingTableViewCell {
            cell.parking = parking
            
            geocoder.reverseGeocodeLocation(location) { results, error in
                DispatchQueue.main.async {
                    if (results?.count ?? 0) > 0 {
                        let result = results!.last!
                        cell.placemark = result
                    } else {
                        cell.placemark = nil
                    }
                }
            }

            return cell
        } else {
            fatalError()
        }
    }
    func loadParkings() {
        parkings = []
        tableView.reloadData()
        
        AppDelegate.service.parkings { result in
            switch result {
            case .error:
                let alert = UIAlertController(title: "載入錯誤", message: "是否重試？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "否", style: .cancel))
                alert.addAction(UIAlertAction(title: "是", style: .default) { _ in self.loadParkings() })
                self.present(alert, animated: true)
            case .success(let parkings):
                self.parkings = parkings
                self.tableView.reloadData()
            }
            
            self.refreshControl.endRefreshing()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = refreshControl
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = "車輛資訊"
        refreshControl.beginRefreshing()
        loadParkings()
    }
}
