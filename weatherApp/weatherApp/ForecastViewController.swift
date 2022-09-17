import UIKit

class ForecastViewController: UIViewController {
    
    var myUrl = URL(string: "")
    var isConnection: Bool = true
    var daysOfWeek: [String] = []
    var maxTemp: [String] = []
    var minTemp: [String] = []
    
    @IBOutlet private var bgView: UIView!
    @IBOutlet private weak var cityNameLabel: UILabel!
    @IBOutlet private weak var degreesLabel: UILabel!
    @IBOutlet private weak var windSpeed: UILabel!
    @IBOutlet private weak var imageWeather: UIImageView!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var todaysDay: UILabel!
    @IBOutlet private weak var highterTemperatureLabel: UILabel!
    @IBOutlet private weak var lowerTemperatureLabel: UILabel!
    @IBOutlet private weak var humidityImage: UIImageView!
    @IBOutlet private weak var windSpeedImage: UIImageView!
    @IBOutlet private weak var visibleLabel: UILabel!
    @IBOutlet private weak var visibleImage: UIImageView!
    @IBOutlet private weak var temperatureUpImage: UIImageView!
    @IBOutlet private weak var temperatureDownImage: UIImageView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var daysOfWeekTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkConnection()
        cityForecast()
        tableViewSettings()
        
        backButton.setImage(UIImage(named: "arrow.svg"), for: .normal)
    }
    
    private func checkConnection() {
        if Reachability.isConnectedToNetwork(){
            isConnection = true
        }
        else {
            isConnection = false
        }
    }
    
    private func tableViewSettings() {
        daysOfWeekTable.delegate = self
        daysOfWeekTable.dataSource = self
        daysOfWeekTable.separatorColor = UIColor.white
        daysOfWeekTable.separatorInset = .zero
    }
    
    private func sunnyOrRainyDayBg(colorTop: CGColor, colorBottom: CGColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    private func cityForecast() {
        
     //   if isConnection == true {
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
                                setAllImages()
                                
                                if forecastResponse.current.condition.text == "Sunny" && forecastResponse.current.temp_c >= 15 || forecastResponse.current.condition.text == "Clear" && forecastResponse.current.temp_c >= 15 {
                                    
                                    sunnyOrRainyDayBg(colorTop: UIColor(red: 255.0/255.0, green: 198.0/255.0, blue: 0/255.0, alpha: 1.0).cgColor, colorBottom: UIColor(red: 235.0/255.0, green: 115.0/255.0, blue: 32.0/255.0, alpha: 1.0).cgColor)
                                    
                                    UserDefaults.standard.set(true, forKey: "bg")
                                }
                                else {
                                   sunnyOrRainyDayBg(colorTop: UIColor(red: 87.0/255.0, green: 154.0/255.0, blue: 230.0/255.0, alpha: 1.0).cgColor, colorBottom: UIColor(red: 55.0/255.0, green: 70.0/255.0, blue: 131.0/255.0, alpha: 1.0).cgColor)
                                    
                                    UserDefaults.standard.set(false, forKey: "bg")
                                }
                                                            
                                cityNameLabel.text = "\(forecastResponse.location.name)"
                                degreesLabel.text = String(Int(forecastResponse.current.temp_c)) + "°"
                                windSpeed.text = String("\(forecastResponse.current.wind_mph) km/h")
                                humidityLabel.text = String("\(forecastResponse.current.humidity)%")
                                highterTemperatureLabel.text = String("\(forecastResponse.forecast.forecastday[0].day.maxtemp_c)°")
                                lowerTemperatureLabel.text = String("\(forecastResponse.forecast.forecastday[0].day.mintemp_c)°")
                                visibleLabel.text = String("\(forecastResponse.current.vis_km) km")
                                
                                maxTemp.append("\(forecastResponse.forecast.forecastday[0].day.maxtemp_c)")
                                maxTemp.append("\(forecastResponse.forecast.forecastday[1].day.maxtemp_c)")
                                maxTemp.append("\(forecastResponse.forecast.forecastday[2].day.maxtemp_c)")
                                
                                minTemp.append("\(forecastResponse.forecast.forecastday[0].day.mintemp_c)")
                                minTemp.append("\(forecastResponse.forecast.forecastday[1].day.mintemp_c)")
                                minTemp.append("\(forecastResponse.forecast.forecastday[2].day.mintemp_c)")
                                
                                switch forecastResponse.current.condition.text {
                                case "Sunny", "Clear":
                                    imageWeather.image = UIImage(named: "sunny.png")
                                case "Moderate or heavy rain with thunder":
                                    imageWeather.image = UIImage(named: "thunderRain.png")
                                case "Partly cloudy":
                                    imageWeather.image = UIImage(named: "partlyCloudy.png")
                                case "Light rain shower", "Moderate rain", "Patchy rain possible", "Light rain":
                                    imageWeather.image = UIImage(named: "lightRainShower.png")
                                case "Patchy light rain with thunder":
                                    imageWeather.image = UIImage(named: "patchyRainPossible.png")
                                case "Overcast":
                                    imageWeather.image = UIImage(named: "overcast.png")
                                default:
                                    print(forecastResponse.current.condition.text)
                                }
                                
                                let todayDay = getDayOfWeek(forecastResponse.forecast.forecastday[0].date, format:"yyyy-MM-dd")
                                todaysDay.text = todayDay
                                daysOfWeek.append(todayDay!)
                                
                                let tomorrowDay = getDayOfWeek(forecastResponse.forecast.forecastday[1].date, format:"yyyy-MM-dd")
                                daysOfWeek.append(tomorrowDay!)
                                
                                let dayAfterTomorrow = getDayOfWeek(forecastResponse.forecast.forecastday[2].date, format:"yyyy-MM-dd")
                                daysOfWeek.append(dayAfterTomorrow!)
                            }
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }.resume()
            
//        } else {
//
//            do {
//                let data = try! Data(contentsOf: myUrl!)
//
//
//
//
//                let forecastResponse = try? JSONDecoder().decode(ForecastsResponse.self, from: data)
//
//                DispatchQueue.main.async { [self] in
//                    setAllImages()
//
//                    if forecastResponse!.current.condition.text == "Sunny" && forecastResponse!.current.temp_c >= 15 || forecastResponse!.current.condition.text == "Clear" && forecastResponse!.current.temp_c >= 15 {
//
//                        sunnyOrRainyDayBg(colorTop: UIColor(red: 255.0/255.0, green: 198.0/255.0, blue: 0/255.0, alpha: 1.0).cgColor, colorBottom: UIColor(red: 235.0/255.0, green: 115.0/255.0, blue: 32.0/255.0, alpha: 1.0).cgColor)
//
//                        UserDefaults.standard.set(true, forKey: "bg")
//                    }
//                    else {
//                       sunnyOrRainyDayBg(colorTop: UIColor(red: 87.0/255.0, green: 154.0/255.0, blue: 230.0/255.0, alpha: 1.0).cgColor, colorBottom: UIColor(red: 55.0/255.0, green: 70.0/255.0, blue: 131.0/255.0, alpha: 1.0).cgColor)
//
//                        UserDefaults.standard.set(false, forKey: "bg")
//                    }
//
//                    cityNameLabel.text = "\(forecastResponse!.location.name)"
//                    degreesLabel.text = String(Int(forecastResponse!.current.temp_c)) + "°"
//                    windSpeed.text = String("\(forecastResponse!.current.wind_mph) km/h")
//                    humidityLabel.text = String("\(forecastResponse!.current.humidity)%")
//                    highterTemperatureLabel.text = String("\(forecastResponse!.forecast.forecastday[0].day.maxtemp_c)°")
//                    lowerTemperatureLabel.text = String("\(forecastResponse!.forecast.forecastday[0].day.mintemp_c)°")
//                    visibleLabel.text = String("\(forecastResponse!.current.vis_km) km")
//
//                    maxTemp.append("\(forecastResponse!.forecast.forecastday[0].day.maxtemp_c)")
//                    maxTemp.append("\(forecastResponse!.forecast.forecastday[1].day.maxtemp_c)")
//                    maxTemp.append("\(forecastResponse!.forecast.forecastday[2].day.maxtemp_c)")
//
//                    minTemp.append("\(forecastResponse!.forecast.forecastday[0].day.mintemp_c)")
//                    minTemp.append("\(forecastResponse!.forecast.forecastday[1].day.mintemp_c)")
//                    minTemp.append("\(forecastResponse!.forecast.forecastday[2].day.mintemp_c)")
//
//                    switch forecastResponse!.current.condition.text {
//                    case "Sunny", "Clear":
//                        imageWeather.image = UIImage(named: "sunny.png")
//                    case "Moderate or heavy rain with thunder":
//                        imageWeather.image = UIImage(named: "thunderRain.png")
//                    case "Partly cloudy":
//                        imageWeather.image = UIImage(named: "partlyCloudy.png")
//                    case "Light rain shower", "Moderate rain", "Patchy rain possible", "Light rain":
//                        imageWeather.image = UIImage(named: "lightRainShower.png")
//                    case "Patchy light rain with thunder":
//                        imageWeather.image = UIImage(named: "patchyRainPossible.png")
//                    case "Overcast":
//                        imageWeather.image = UIImage(named: "overcast.png")
//                    default:
//                        print(forecastResponse!.current.condition.text)
//                    }
//
//                    let todayDay = getDayOfWeek(forecastResponse!.forecast.forecastday[0].date, format:"yyyy-MM-dd")
//                    todaysDay.text = todayDay
//                    daysOfWeek.append(todayDay!)
//
//                    let tomorrowDay = getDayOfWeek(forecastResponse!.forecast.forecastday[1].date, format:"yyyy-MM-dd")
//                    daysOfWeek.append(tomorrowDay!)
//
//                    let dayAfterTomorrow = getDayOfWeek(forecastResponse!.forecast.forecastday[2].date, format:"yyyy-MM-dd")
//                    daysOfWeek.append(dayAfterTomorrow!)
//
//                }
//            }
//        }
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
    
    private func setAllImages() {
        let imageWindSpeed = UIImage(named: "windSpeed.png")
        self.windSpeedImage.image = imageWindSpeed
        
        let humidityImage = UIImage(named: "humidity.png")
        self.humidityImage.image = humidityImage
        
        let visibleImage = UIImage(named: "visible.png")
        self.visibleImage.image = visibleImage
        
        let temperatureUpImage = UIImage(named: "temperatureUp.png")
        self.temperatureUpImage.image = temperatureUpImage
        
        let temperatureDownImage = UIImage(named: "temperatureDown.png")
        self.temperatureDownImage.image = temperatureDownImage
    }
    
    @IBAction func getBackAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension ForecastViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = daysOfWeekTable.dequeueReusableCell(withIdentifier: "daysCell", for: indexPath) as! DaysTableViewCell
        
        if daysOfWeek .isEmpty {
            daysOfWeekTable.reloadData()
        } else {
            cell.labelDay.text = daysOfWeek[indexPath.row]
            cell.maxTemperature.text = "\(maxTemp[indexPath.row])°"
            cell.minTemperature.text = "\(minTemp[indexPath.row])°"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch daysOfWeek[indexPath.item] {
        case daysOfWeek[indexPath.item]:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let aboutDayViewController = storyboard.instantiateViewController(identifier: "AboutDayViewController") as? AboutDayViewController {
                aboutDayViewController.modalPresentationStyle = .fullScreen
                
                aboutDayViewController.myUrl = myUrl
                aboutDayViewController.indexPath = indexPath.row
 
                navigationController?.pushViewController(aboutDayViewController, animated: true)
            }
        default:
            print("not found")
        }
    }
}
