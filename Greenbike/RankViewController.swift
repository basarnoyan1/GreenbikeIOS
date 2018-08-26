import CoreBluetooth
import UIKit

class RankViewController: UIViewController {
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var back: UIButton!
    
    var json:[String:AnyObject] = [:]
    
    struct Rank {
        var rank: String
        var name: String
        var dist: String
        var tree: String
        var time: String
        var carbo: String
        var energy: String
        var speed: String
        var owner: String
    }
    
    var tableData: [Rank] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progress.startAnimating()
        let preferences = UserDefaults.standard
        let salt = preferences.string(forKey: "salt")
        let url = URL(string: "http://greenbike.evall.io/api.php?actionid=200&salt=\(salt ?? "nil")")
        let task = URLSession.shared.dataTask(with: url!){ (data,response,error) in
            if error != nil {
                print(error!)
            } else {
                if let urlContent = data {
                    do{
                        self.json = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                        if let usJson = self.json["userdata"] as? [[String: Any]] {
                            for jsn in usJson {
                                if ((jsn["dist"] as? NSNull) == nil) {
                                    self.tableData.append(Rank(rank: jsn["rank"] as! String, name: jsn["username"] as! String, dist: jsn["dist"] as! String, tree: jsn["tree"] as! String, time: jsn["cycletime"] as! String, carbo: jsn["gas"] as! String, energy: jsn["energy"] as! String, speed: jsn["speed"] as! String, owner: jsn["owner"] as! String ))
                                }
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
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

extension RankViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RankViewCell = self.tableView.dequeueReusableCell(withIdentifier: "rankProto")! as! RankViewCell
        cell.rank.text = tableData[indexPath.row].rank
        cell.name.text = tableData[indexPath.row].name
        cell.dist.text = "\(tableData[indexPath.row].dist) km"
        cell.tree.text = "\(tableData[indexPath.row].tree) ağaç"
        cell.time.text = tableData[indexPath.row].time
        cell.carbo.text = "\(tableData[indexPath.row].carbo) g CO2"
        cell.energy.text = "\(tableData[indexPath.row].energy) cal"
        cell.speed.text = "\(tableData[indexPath.row].speed) km/h"
        if tableData[indexPath.row].owner == "1" {
            cell.backgroundColor = UIColor(red: 1, green: 139/255, blue: 103/255, alpha: 80/255)
        }
        progress.stopAnimating()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tableData.count)
        return tableData.count
    }

}






