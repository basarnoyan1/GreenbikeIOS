import CoreBluetooth
import UIKit

class ViewController: UIViewController{
    var centralManager: CBCentralManager?
    var peripherals = Array<CBPeripheral>()
    private var viewReloadTimer: Timer?
    
    private var selectedPeripheral: CBPeripheral?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? BikeViewController{
            destinationViewController.setup(with: centralManager!, peripheral: selectedPeripheral!)
        }
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            // do something like alert the user that ble is not on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripherals.append(peripheral)
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        let peripheral = peripherals[indexPath.row]
        if peripheral.name!.hasPrefix("GREENBIKE"){
            cell.textLabel?.text = peripheral.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPeripheral = peripherals[indexPath.row]
        centralManager?.connect(peripherals[indexPath.row], options: nil)
        print(peripherals[indexPath.row].state == .connected)
        performSegue(withIdentifier: "startCycle", sender: self)
    }
}
