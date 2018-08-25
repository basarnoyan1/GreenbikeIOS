import UIKit

class CreateViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var hei: UITextField!
    @IBOutlet weak var wei: UITextField!
    @IBOutlet weak var ge: UISegmentedControl!
    @IBOutlet weak var create: UIButton!
    @IBOutlet weak var warn: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        if !((name.text?.isEmpty)! || (age.text?.isEmpty)! || (hei.text?.isEmpty)! || (wei.text?.isEmpty)!) {
            warn.alpha = 0
            var g = "Erkek"
            let preferences = UserDefaults.standard
            let a = name.text
            preferences.set(a, forKey: "name")
            preferences.set(Int(age.text!), forKey: "age")
            preferences.set(Int(hei.text!), forKey: "hei")
            preferences.set(Int(wei.text!), forKey: "wei")
            if ge.selectedSegmentIndex == 1{
                g = "Kadın"
            }
            preferences.set(g, forKey: "gender")
        
            let url = URL(string: "http://greenbike.evall.io/api.php")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "username")
            request.httpMethod = "POST"
            let postString = "actionid=200&username=\(a ?? "null")"
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
                
                let dat = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                do {
                    let json = try JSONSerialization.jsonObject(with: dat!, options: []) as! [String: AnyObject]
                    if let usJson = json["userdata"] as? Dictionary<String, Any> {
                        print(usJson["salt"] ?? "nil")
                        let salt = usJson["salt"]
                        preferences.set(salt, forKey: "salt")
                    }
                    
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                
            }
            task.resume()

        performSegue(withIdentifier: "created", sender: self)
    }
        else{
            warn.alpha = 1
        }
    }
}
