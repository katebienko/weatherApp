import UIKit

class AboutDayViewController: UIViewController {
    
    var myUrl = URL(string: "")
    var indexPath: Int = 0
    
    @IBOutlet private weak var daysName: UILabel!
    @IBOutlet private weak var getBackButton: UIButton!
    @IBOutlet private weak var maxTemperatureLabel: UILabel!
    @IBOutlet private weak var minTemperatureLabel: UILabel!
    @IBOutlet private weak var avgTemperatureLabel: UILabel!
    @IBOutlet private weak var windSpeedLabel: UILabel!
    @IBOutlet private weak var totalPrecipLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cityForecast()

        getBackButton.setImage(UIImage(named: "arrow.svg"), for: .normal)        

            switch UserDefaults.standard.value(forKey: "bg") as! Bool {
            case true:
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [UIColor(red: 255.0/255.0, green: 198.0/255.0, blue: 0/255.0, alpha: 1.0).cgColor, UIColor(red: 235.0/255.0, green: 115.0/255.0, blue: 32.0/255.0, alpha: 1.0).cgColor]
                gradientLayer.locations = [0.0, 1.0]
                gradientLayer.frame = self.view.bounds
                
                self.view.layer.insertSublayer(gradientLayer, at:0)
            
            default:
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [UIColor(red: 87.0/255.0, green: 154.0/255.0, blue: 230.0/255.0, alpha: 1.0).cgColor, UIColor(red: 55.0/255.0, green: 70.0/255.0, blue: 131.0/255.0, alpha: 1.0).cgColor]
                gradientLayer.locations = [0.0, 1.0]
                gradientLayer.frame = self.view.bounds
                
                self.view.layer.insertSublayer(gradientLayer, at:0)
        }
    }
    
    private func cityForecast() {
        let session = URLSession(configuration: .default)
            session.dataTask(with: myUrl!) { (data, response, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
        
                    guard let data = data else {
                        return
                    }
        
                    do {
                        let forecastResponse = try JSONDecoder().decode(ForecastsResponse.self, from: data)
                        
                        DispatchQueue.main.async { [self] in
                            daysName.text = getDayOfWeek(forecastResponse.forecast.forecastday[indexPath].date, format: "yyyy-MM-dd")
                            
                            maxTemperatureLabel.text = "\(forecastResponse.forecast.forecastday[indexPath].day.maxtemp_c)°"
                            
                            minTemperatureLabel.text = "\(forecastResponse.forecast.forecastday[indexPath].day.mintemp_c)°"
                            
                            avgTemperatureLabel.text = "\(forecastResponse.forecast.forecastday[indexPath].day.avgtemp_c)°"
                            
                            windSpeedLabel.text = "\(forecastResponse.forecast.forecastday[indexPath].day.maxwind_kph)"
                            
                            totalPrecipLabel.text = "\(forecastResponse.forecast.forecastday[indexPath].day.totalprecip_mm)"
                        }
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }.resume()
    }
    
    @IBAction func getBackAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func getDayOfWeek(_ date:String, format: String) -> String? {
        let weekDays = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]

        let formatter  = DateFormatter()
        formatter.dateFormat = format
        guard let myDate = formatter.date(from: date) else { return nil }
        
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: myDate)
        
        return weekDays[weekDay-1]
    }
}
