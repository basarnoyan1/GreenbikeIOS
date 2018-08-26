import CoreBluetooth
import UIKit

class HistoryViewController: UIViewController{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var back: UIButton!
    var textArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let file = "file.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                textArray = text.components(separatedBy: "\n")
                tableView.reloadData()
                print(text)
            } catch {}
        }
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "HisttoEntry", sender: self)
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "histProto")! as UITableViewCell
        cell.textLabel?.text = textArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textArray.count
    }
}
