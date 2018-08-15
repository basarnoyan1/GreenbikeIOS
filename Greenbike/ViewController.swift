import CoreBluetooth
import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let sections = ["Fruit", "Vegetables"]
    let fruit = ["Apple", "Orange", "Mango"]
    let vegetables = ["Carrot", "Broccoli", "Cucumber"]
    
    override func viewDidLoad() {super.viewDidLoad()}
    override func didReceiveMemoryWarning() {super.didReceiveMemoryWarning()}
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return fruit.count
            case 1:
                return vegetables.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch indexPath.section {
            case 0:
                cell.textLabel?.text = fruit[indexPath.row]
                break
            case 1:
                cell.textLabel?.text = vegetables[indexPath.row]
                break
            default:
                break
        }
        return cell
    }
    

}
