import UIKit
import CoreLocation

class RecordsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(reloadRecords), for: .valueChanged)
        return control
    }()
//    lazy var geocoder: CLGeocoder = {
//        return CLGeocoder()
//    }()
    var records: [PKRecord] = []
    
    func reloadRecords() {
        refreshControl.beginRefreshing()
        
        records = []
        tableView.reloadData()
        
        AppDelegate.service.records { result in
            switch result {
            case .error:
                let alert = UIAlertController(title: "載入錯誤", message: "是否重試？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "否", style: .cancel))
                alert.addAction(UIAlertAction(title: "是", style: .default) { _ in self.reloadRecords() })
                self.present(alert, animated: true)
            case .success(let records):
                self.records = records
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
        navigationController?.navigationBar.topItem?.title = "停車紀錄"
        
        reloadRecords()
    }
    
    // MARK: TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = records[indexPath.row]
        let location = CLLocation(latitude: record.space.location.latitude, longitude: record.space.location.longitude)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell") as? RecordTableViewCell {
            cell.record = record
//            geocoder.reverseGeocodeLocation(location) { results, error in
//                DispatchQueue.main.async {
//                    if (results?.count ?? 0) > 0 {
//                        let result = results!.last!
//                        cell.placemark = result
//                    } else {
//                        cell.placemark = nil
//                    }
//                }
//            }
            
            return cell
        } else {
            fatalError()
        }
    }
}
