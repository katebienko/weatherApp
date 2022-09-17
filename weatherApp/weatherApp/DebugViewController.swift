import UIKit

class DebugViewController: UIViewController {

    @IBOutlet weak var loadFromAPIButton: UIButton!
    @IBOutlet weak var loadFromJSONButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loadFromJSON(_ sender: Any) {
        UserDefaults.standard.setValue(false, forKey: "isConnection")
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func loadFromAPI(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: "isConnection")
        navigationController?.popToRootViewController(animated: true)
    }
}
