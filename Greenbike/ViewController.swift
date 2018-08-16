import CoreBluetooth
import UIKit

class ViewController: UIViewController{
    var centralManager: CBCentralManager?
    var peripherals = Array<CBPeripheral>()
    private var viewReloadTimer: Timer?
    
    private var selectedPeripheral: CBPeripheral?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rankBtn: UIButton!
    @IBOutlet weak var histBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? BikeViewController{
            destinationViewController.setup(with: centralManager!, peripheral: selectedPeripheral!)
        }
    }
    
    @IBAction func rankOnClick(_ sender: UIButton) {
         performSegue(withIdentifier: "MaintoRanklist", sender: self)
    }
    
    @IBAction func histOnClick(_ sender: UIButton) {
         performSegue(withIdentifier: "MaintoHistory", sender: self)
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

extension ViewController: CBPeripheralDelegate {
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            var errorMessage = "Could not connect"
            if let selectedPeripheralName = self.selectedPeripheral?.name {
                errorMessage += " \(selectedPeripheralName)"
            }
            
            if let error = error {
                print("Error connecting peripheral: \(error.localizedDescription)")
                errorMessage += "\n \(error.localizedDescription)"
            }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("Peripheral connected")
            performSegue(withIdentifier: "startCycle", sender: self)
            peripheral.discoverServices(nil)
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
    }
}
