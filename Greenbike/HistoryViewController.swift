import CoreBluetooth
import UIKit

class HistoryViewController: UIViewController{
    @IBOutlet weak var back: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let file = "file.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                print(text2)
            }
            catch {}
        }
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "HisttoEntry", sender: self)
    }
}
