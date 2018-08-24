import CoreBluetooth
import UIKit

class RankViewController: UIViewController {
    @IBOutlet weak var back: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://greenbike.evall.io/api.php?actionid=200&salt=ec2e90a1ab8f")
        let task = URLSession.shared.dataTask(with: url!){ (data,response,error) in
            if error != nil {
                print(error!)
            } else {
                if let urlContent = data {
                    do{
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        print(jsonResult)
                    } catch {
                        print("Error")
                    }
                }
            }
        }
        task.resume()
        
    }
    @IBAction func onBackPressed(_ sender: UIButton) {
            performSegue(withIdentifier: "RanktoEntry", sender: self)
    }

}
