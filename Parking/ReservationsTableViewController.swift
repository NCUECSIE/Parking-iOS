import UIKit
import CoreLocation

class ReservationsTableViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
//    lazy var geocoder: CLGeocoder = {
//        return CLGeocoder()
//    }()
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(reloadReservation), for: .valueChanged)
        return control
    }()
    lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(makeReservation))
    }()
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = addButton
        navigationController?.navigationBar.topItem?.title = "預約"
        
        refreshControl.beginRefreshing()
        reloadReservation()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reservation = reservations[indexPath.row]
        let location = CLLocation(latitude: reservation.space.location.latitude, longitude: reservation.space.location.longitude)
        if let view = tableView.dequeueReusableCell(withIdentifier: "ReservationCell") as? ReservationTableViewCell {
            view.reservation = reservation
//            geocoder.reverseGeocodeLocation(location) { results, error in
//                DispatchQueue.main.async {
//                    if (results?.count ?? 0) > 0 {
//                        let result = results!.last!
//                        view.placemark = result
//                    } else {
//                        view.placemark = nil
//                    }
//                }
//            }
            
            return view
        } else {
            fatalError()
        }
    }
    
    // MARK: Model
    var reservations: [PKReservation] = []
    func reloadReservation() {
        reservations = []
        tableView.reloadData()
        
        AppDelegate.service.reservations { result in
            switch result {
            case .error:
                let alert = UIAlertController(title: "載入錯誤", message: "是否重試？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "否", style: .cancel))
                alert.addAction(UIAlertAction(title: "是", style: .cancel) { _ in self.reloadReservation() })
                self.present(alert, animated: true)
            case .success(let reservations):
                self.reservations = reservations
                self.tableView.reloadData()
            }
            
            self.refreshControl.endRefreshing()
        }
    }
    
    var reservationIsAround: CLLocationCoordinate2D? = nil
    // MARK: Prepare for Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PKSegueIdentifiers.reserve.rawValue {
            let destination = segue.destination as! ReserveViewController
            destination.selectedGrid = reservationIsAround
        } else if segue.identifier == PKSegueIdentifiers.showReservation.rawValue {
            let reservationTableViewCell = sender! as! ReservationTableViewCell
            let destination = segue.destination as! ReservationViewController
            
            destination.reservation = reservationTableViewCell.reservation
            destination.placemark = reservationTableViewCell.placemark
        }
    }
    
    // MARK: Triggers Storyboard Segue
    @objc func makeReservation() {
        makeReservation(around: nil)
    }
    func makeReservation(around: CLLocationCoordinate2D? = nil) {
        reservationIsAround = around
        performSegue(withIdentifier: PKSegueIdentifiers.reserve.rawValue, sender: nil)
    }
}
