import UIKit

class CitiesCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var citieLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(cityNames: String, cityTemperatures: String) {
        citieLabel.text = cityNames
        temperatureLabel.text = "\(cityTemperatures)"
    }
}
