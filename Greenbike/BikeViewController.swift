import UIKit
import CoreBluetooth

class BikeViewController: UIViewController{
    
    var peripheral: CBPeripheral!
    var centralManager: CBCentralManager!
    
    private var rssiReloadTimer: Timer?
    private var services: [CBService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral.delegate = self
        rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BikeViewController.refreshRSSI), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        rssiReloadTimer?.invalidate()
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func setup(with centralManager: CBCentralManager, peripheral: CBPeripheral) {
        self.centralManager = centralManager
        self.peripheral = peripheral
    }
    
    @objc private func refreshRSSI(){
        peripheral.readRSSI()
    }
}

var characteristicUUID = CBUUID(string: "FFE1")

extension BikeViewController: CBPeripheralDelegate {
    func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let error = error {
            print("Error connecting peripheral: \(error.localizedDescription)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
        }
        
        peripheral.services?.forEach({ (service) in
            services.append(service)
            peripheral.discoverCharacteristics(nil, for: service)
        })
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            if characteristic.uuid == characteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let rxData = characteristic.value
        if let rxData = rxData {
            let numberOfBytes = rxData.count
            var rxByteArray = [UInt8](repeating: 0, count: numberOfBytes)
            (rxData as NSData).getBytes(&rxByteArray, length: numberOfBytes)
            if let string = String(bytes: rxByteArray, encoding: .utf8) {
                print(string)
            } else {
                print("not a valid UTF-8 sequence")
            }
        }
    }
}
