import UIKit
import CoreBluetooth

class BikeViewController: UIViewController{
    
    var peripheral: CBPeripheral!
    var centralManager: CBCentralManager!
    
    var timer = Timer()
    var lat_tim:Int = 0
    var lat_spd:Double = 0
    var counter:Int = 0
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
    
    @IBAction func saveOnClick(_ sender: UIButton) {
        savef()
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
    
    @objc private func tick(){
        counter += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: counter/1000)
        time.text = String(format: "%02d",h) + ":" + String(format: "%02d",m) + ":" + String(format: "%02d",s)
        if counter - lat_tim > 1500 {
            lat_spd = Double(3600) * Double(0.66 * Float.pi) / Double(counter - lat_tim)
            speed.text = String(format: "%.1f", Float(lat_spd)) + " km/h"
        }
        energy.text = getCal(gender: "Erkek", he: 180, we: 70, ag: 35, spe: lat_spd, time: counter/1000)
    }
    
    func savef(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.y HH:mm:ss"
        let date = formatter.string(from: Date())
        
        let savetxt =  date + "\t" + dist.text + "\t" + time.text + "\t" + speed.text + "\t" + energy.text + "\t" + tour.text + "\t" + tree.text + "\t" + cdio.text + "\n"
        
        counter = 0
        
        dist.text = "0 km"
        time.text = "00:00:00"
        speed.text = "0 km/h"
        energy.text = "0 cal"
        tour.text = "0 tur"
        tree.text = "0 ağaç"
        cdio.text = "0 g CO2"
        
    }
    
    func getCal(gender:String, he:Int,we:Int,ag:Int,spe:Double,time:Int) -> String{
        var bmr = Double(0.00)
        var mets = Double(0.00)
            let n_we = Double(10*we)
            let n_he = 6.25 * Double(he)
            let n_ag = Double(5 * ag)
        if (gender == "Erkek") {
            bmr = n_we + n_he - n_ag + Double(5)
        } else {
            bmr = n_we + n_he - n_ag - Double(161)
        }
        
        if (spe < 0) {
            mets = 1
        } else if (spe < 5) {
            mets = Double(3.8 - (5 - spe) * 2 / 9)
        } else if (spe < 10) {
            mets = Double(4.8 - (10 - spe) * 2 / 10)
        } else if (spe < 15) {
            mets = Double(5.9 - (15 - spe) * 2 / 11)
        } else if (spe < 20) {
            mets = Double(7.1 - (20 - spe) * 2 / 12)
        } else if (spe < 25) {
            mets = Double(8.4 - (25 - spe) * 2 / 13)
        } else if (spe < 30) {
            mets = Double(9.8 - (30 - spe) * 2 / 14)
        } else if (spe < 35) {
            mets = Double(11.3 - (35 - spe) * 2 / 15)
        } else if (spe < 40) {
            mets = Double(12.9 - (40 - spe) * 2 / 16)
        } else if (spe < 45) {
            mets = Double(14.6 - (45 - spe) * 2 / 17)
        } else if (spe < 50) {
            mets = Double(16.4 - (50 - spe) * 2 / 18)
        } else {
            mets = 18.3
        }
        let test = Decimal(time)/Decimal(360)*Decimal(bmr)*Decimal(mets)/Decimal(240)
        let res = String(format:"%.1f",Float(test.description)!) + " cal"
        return res
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
                    if counter - lat_tim != 0 {
                        lat_spd = Double(3600) * Double(0.66 * Float.pi) / Double(counter - lat_tim)
                        speed.text = String(format: "%.1f", Float(lat_spd)) + " km/h"
                    }
                        let trstr = Decimal(counter) * Decimal(6.25) / Decimal(100000000)
                    tree.text = String(format:"%.2f",Float(trstr.description)!) +  " ağaç"
                        let enstr = Decimal(counter) * Decimal(0.125) / Decimal(1000)
                    cdio.text = String(format:"%.2f",Float(enstr.description)!) + " g CO2"
                    lat_tim = counter
                }
                
                
                
            } else {
                print("not a valid UTF-8 sequence")
            }
        }
    }
}

