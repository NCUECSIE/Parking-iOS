import UIKit

class ReservationsTableViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let view = tableView.dequeueReusableCell(withIdentifier: "ReservationCell") {
            return view
        } else {
            fatalError()
        }
    }
}
