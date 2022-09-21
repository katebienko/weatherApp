import UIKit

class DebugViewController: UIViewController {

    @IBOutlet weak var loadFromAPIButton: UIButton!
    @IBOutlet weak var loadFromJSONButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loadFromJSON(_ sender: Any) {
        UserDefaults.standard.setValue(false, forKey: "isConnection")
        UserDefaults.standard.setValue(false, forKey: "loadFromJSON")
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func loadFromAPI(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: "isConnection")
        UserDefaults.standard.setValue(true, forKey: "loadFromJSON")
        navigationController?.popToRootViewController(animated: true)
    }
}
