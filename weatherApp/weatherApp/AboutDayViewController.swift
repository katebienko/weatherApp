import UIKit

class AboutDayViewController: UIViewController {
    
    var myUrl = URL(string: "")
    var indexPath: Int = 0
    
    @IBOutlet private weak var daysName: UILabel!
    @IBOutlet private weak var getBackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cityForecast()

        getBackButton.setImage(UIImage(named: "arrow.svg"), for: .normal)
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
                            let todayDay = getDayOfWeek(forecastResponse.forecast.forecastday[indexPath].date, format:"yyyy-MM-dd")
                            daysName.text = todayDay
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
