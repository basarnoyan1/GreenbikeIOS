import UIKit
import CoreBluetooth

class BikeViewController: UIViewController{
    
    var peripheral: CBPeripheral!
    var centralManager: CBCentralManager!

    var disc = false
    var saving:Bool = false
    var timer = Timer()
    var lat_tim:Int = 0
    var lat_spd:Double = 0
    var counter:Int = 0
    var first = true
    var cyc = 0
    
    var h = false
    var r = false
    
    @IBOutlet weak var hist: UIButton!
    @IBOutlet weak var rank: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var backgr: UIView!
    
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
    
    var hst:String = ""
    var onamae:String = ""
    var gen:String = ""
    var salt:String = ""
    var age:Int = 0
    var hei:Int = 0
    var wei:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral.delegate = self
        rssiReloadTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BikeViewController.refreshRSSI), userInfo: nil, repeats: true)
        let preferences = UserDefaults.standard
        hst = preferences.string(forKey: "history")!
        onamae = preferences.string(forKey: "name")!
        gen = preferences.string(forKey: "gender")!
        salt = preferences.string(forKey: "salt")!
        age = preferences.integer(forKey: "age")
        hei = preferences.integer(forKey: "hei")
        wei = preferences.integer(forKey: "wei")
        name.text = "Merhaba, \(onamae )!"
        
        let img = UIImage(named: "blue")
        backgr.backgroundColor = UIColor (patternImage: img!)
        
        hist.imageView?.contentMode = .scaleAspectFit
        rank.imageView?.contentMode = .scaleAspectFit
        save.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func histShow(_ sender: UIButton) {
        if counter != 0{
            savef()
        }
        h = true
        performSegue(withIdentifier: "BiketoHist", sender: self)
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    @IBAction func rankShow(_ sender: UIButton) {
        if counter != 0{
            savef()
        }
        r = true
        performSegue(withIdentifier: "BiketoRank", sender: self)
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    @IBAction func saveOnClick(_ sender: UIButton) {
        if(dist.text != "0 km"){
            savef()
        }
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
        if peripheral.state == .disconnected{
            if disc==false && counter==0 && saving==false && h == false && r == false {
                disc = true
                performSegue(withIdentifier: "list", sender: self)
            }
        }
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
        energy.text = getCal(gender: gen, he: hei, we: wei, ag: age, spe: lat_spd, time: counter/1000)

        if peripheral.state == .disconnected{
            savef()
        }
    }
    
    func savef(){
        
        saving = true
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.y HH:mm:ss"
        let date = formatter.string(from: Date())
        var savetxt = "\(date)\t\(dist.text ?? "0 km")\t\(time.text ?? "00:00:00")\t\(speed.text ?? "0 km/h")\t\(energy.text ?? "0 cal")\t\(tour.text ?? "0 tur")\t\(tree.text ?? "0 ağaç")\t\(cdio.text ?? "0 g CO2")\n"
        let preferences = UserDefaults.standard
        preferences.set(hst + savetxt,forKey: "history")
        
        let alertController = UIAlertController(title: "Ürettiğin elektrik enerjisiyle:", message: "\(appr_time(code: 0))su ısıtıcısı,\n\(appr_time(code: 1)) ampul,\n\(appr_time(code: 2)) klima çalıştırabilir ve\n\(appr_time(code: 3))basınçlı hava üretebilirdin.", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Tamam", style: .default) {
            (action:UIAlertAction!) in
            self.saving = false
        }
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        
        let d2 = dist.text?.dropLast(3) ?? ""
        let s2 = speed.text?.dropLast(5) ?? ""
        let e2 = energy.text?.dropLast(4) ?? ""
        let t2 = tree.text?.dropLast(5) ?? ""
        let g2 = cdio.text?.dropLast(6) ?? ""
        
        let url = URL(string: "http://greenbike.evall.io/api.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "username")
        request.httpMethod = "POST"
        
        let postString = "username=\(onamae)&salt=\(salt)&dist=\(d2)&time=\(time.text)&speed=\(s2)&energy=\(e2)&cycle=\(cyc)&tree=\(t2)&gas=\(g2)&actionid=400"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            
        }
        task.resume()
        
        
        resetValues()
    }
    
    func resetValues(){
        counter = 0
        timer.invalidate()
        lat_tim = 0
        lat_spd = 0
        cyc = 0
        first = true
        
        dist.text = "0 km"
        time.text = "00:00:00"
        speed.text = "0 km/h"
        energy.text = "0 cal"
        tour.text = "0 tur"
        tree.text = "0 ağaç"
        cdio.text = "0 g CO2"
    }
    
    func appr_time(code:Int) -> String {
        var res:String = ""
        switch code {
        case 0:
            let mizu = Decimal(counter) / Decimal(21600000)
            let mizu_ = String(format:"%.2f",Float(mizu.description)!)
            res = "\(mizu_) kez "
            return res
        case 1:
            let denkyu = Decimal(counter) * Decimal(60) / Decimal(16)
            
            let date = NSDate(timeIntervalSince1970: Double(denkyu.description)! / 1000)
            let formatter = DateFormatter()
            formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            formatter.dateFormat = "HH:mm:ss"
            res = formatter.string(from: date as Date)
            return res
        case 2:
            let kuchosochi = Decimal(counter) * Decimal(10) / Decimal(35)
            let date = NSDate(timeIntervalSince1970: Double(kuchosochi.description)! / 1000)
            let formatter = DateFormatter()
            formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            formatter.dateFormat = "HH:mm:ss"
            res = formatter.string(from: date as Date)
            
            return res
        case 3:
            let kuki = Decimal(counter)/Decimal(540000)
            let kuki_ = String(format:"%.1f",Float(kuki.description)!)
            res = "\(kuki_) s "
            return res
        default:
            return res
        }
        
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
                    if saving == false{
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
                }
            } else {
                print("not a valid UTF-8 sequence")
            }
        }
    }
}



