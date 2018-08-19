import CoreBluetooth
import UIKit

class HistoryViewController: UIViewController{
    @IBOutlet weak var back: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func onBackPressed(_ sender: UIButton) {
            performSegue(withIdentifier: "HisttoEntry", sender: self)
    }
}
