import CoreBluetooth
import UIKit

class HistoryViewController: UIViewController{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var back: UIButton!
    var textArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let preferences = UserDefaults.standard
        let hst = preferences.string(forKey: "history")
        textArray = hst!.components(separatedBy: "\n")
        textArray.removeLast()
        textArray.reverse()
        tableView.reloadData()
        print(hst)
        
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "HisttoEntry", sender: self)
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "histProto")! as UITableViewCell
        cell.textLabel?.text = "\(textArray[indexPath.row])"
        cell.textLabel?.numberOfLines=0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textArray.count
    }
}
