import UIKit
import CoreBluetooth

class BikeViewController: UIViewController{
    
    var peripheral: CBPeripheral!
    var centralManager: CBCentralManager!
    
    var timer = Timer()
    var counter = 0
    var first = true
    var cyc = 0
    
    @IBOutlet weak var hist: UIButton!
    @IBOutlet weak var rank: UIButton!
    @IBOutlet weak var save: UIButton!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var tour: UILabel!
    @IBOutlet weak var dist: UILabel!
    @IBOutlet weak var tree: UILabel!
    @IBOutlet weak var cdio: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var energy: UILabel!
    @IBOutlet weak var time: UILabel!
    
    private var rssiReloadTimer: Timer?
    private var services: [CBService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral.delegate = self
        rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BikeViewController.refreshRSSI), userInfo: nil, repeats: true)
        hist.imageView?.contentMode = .scaleAspectFit
        rank.imageView?.contentMode = .scaleAspectFit
        save.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func histShow(_ sender: UIButton) {
        performSegue(withIdentifier: "BiketoHist", sender: self)
    }
    
    @IBAction func rankShow(_ sender: UIButton) {
        performSegue(withIdentifier: "BiketoRank", sender: self)
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
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func tick(){
        counter += 1
        var (h,m,s) = secondsToHoursMinutesSeconds(seconds: counter/1000)
        time.text = String(format: "%02d",h) + ":" + String(format: "%02d",m) + ":" + String(format: "%02d",s)
        energy.text = getCal(gender: "Erkek", he: 180, we: 70, ag: 35, spe: 40, time: counter/1000)
    }
    func getCal(gender:String, he:Int,we:Int,ag:Int,spe:Float,time:Int) -> String{
        var bmr = 0
        var mets = 0
        if (gender == "Erkek") {
            bmr = 10 * we + 6.25 * he - 5 * ag + 5
        } else {
            bmr = 10 * we + 6.25 * he - 5 * ag - 161
        }
        
        if (spe < 0) {
            mets = 1
        } else if (spe < 5) {
            mets = 3.8 - (5 - spe) * 2 / 9
        } else if (spe < 10) {
            mets = 4.8 - (10 - spe) * 2 / 10
        } else if (spe < 15) {
            mets = 5.9 - (15 - spe) * 2 / 11
        } else if (spe < 20) {
            mets = 7.1 - (20 - spe) * 2 / 12
        } else if (spe < 25) {
            mets = 8.4 - (25 - spe) * 2 / 13
        } else if (spe < 30) {
            mets = 9.8 - (30 - spe) * 2 / 14
        } else if (spe < 35) {
            mets = 11.3 - (35 - spe) * 2 / 15
        } else if (spe < 40) {
            mets = 12.9 - (40 - spe) * 2 / 16
        } else if (spe < 45) {
            mets = 14.6 - (45 - spe) * 2 / 17
        } else if (spe < 50) {
            mets = 16.4 - (50 - spe) * 2 / 18
        } else {
            mets = 18.3
        }
        
        return String(format:"%01d",time/3600*bmr*mets*24) + " cal"
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
                if string.hasPrefix("#b4z8"){
                    if first{
                        timer = Timer.scheduledTimer(timeInterval: 0.001, target:self, selector: #selector(BikeViewController.tick), userInfo: nil, repeats: true)
                        first = false
                    }
                    cyc += 1
                    tour.text = String(cyc) + " tur"
                    dist.text = String(format: "%.3f", (Float(cyc) * 0.66 * Float.pi / 1000)) + " km"
                }
                
                
                
            } else {
                print("not a valid UTF-8 sequence")
            }
        }
    }
}
