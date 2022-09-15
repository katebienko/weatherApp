import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    private var locationManager = CLLocationManager()
    private var coordinates: CLLocationCoordinate2D?
    
    var countryNames: [String] = ["London", "Minsk"]
    var temperaturesCountry: [URL] = [].compactMap { URL(string: $0) }
    var allCities: [String] = []
    var filterData: [String]!
    
    @IBOutlet private var bgView: UIView!
    @IBOutlet private weak var forecastCollectionView: UICollectionView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.distanceFilter = 1
             
        for name in countryNames {
            let newString = name.replacingOccurrences(of: " ", with: "%20")
            addCity(name: newString)
        }
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        filterData = allCities
        
        setupCollectionView()
        backgroundView()
        loadJSON()
    }
    
    private func loadJSON() {
        if let path = Bundle.main.path(forResource: "json_file", ofType: nil) {
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data)
                
                let arrayOfDicts = json as? [[String: Any]] ?? []
               
                for dict in arrayOfDicts {
                    if let names = dict["name"] as? String {
                        allCities.append(names)
                    }
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func backgroundView() {
        let colorTop =  UIColor(red: 176.0/255.0, green: 191.0/255.0, blue: 206/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 96.0/255.0, green: 103.0/255.0, blue: 130.0/255.0, alpha: 1.0).cgColor
                       
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
                   
        view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    private func setupCollectionView() {
        forecastCollectionView.reloadData()
        
        let key = CitiesCollectionViewCell.reuseIdentifier
        
        forecastCollectionView.register(UINib(nibName: key, bundle: nil), forCellWithReuseIdentifier: key)
        forecastCollectionView.dataSource = self
        forecastCollectionView.delegate = self
        forecastCollectionView.reloadData()
    }
    
    private func addCity(name: String) {
        let newString = name.replacingOccurrences(of: " ", with: "%20")
        temperaturesCountry.append(URL(string:"https://api.weatherapi.com/v1/forecast.json?key=e5c76c2a09fa483da4e65137222306&q=\(newString)&days=7")!)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return countryNames.count
    }
        
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CitiesCollectionViewCell.reuseIdentifier, for: indexPath) as? CitiesCollectionViewCell else {
            fatalError()
        }
        
        let url = temperaturesCountry[indexPath.item]
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, response, error) in
        
            if let error = error {
                print(error)
                
                return
            }
            guard let data = data else { return }
            
            do {
                let forecastResponse = try JSONDecoder().decode(ForecastsResponse.self, from: data)
                    
                DispatchQueue.main.sync { [self] in
                    let tempInt = String(Int(forecastResponse.current.temp_c)) + "°"
                    cell.setup(countryNames: "\(countryNames[indexPath.item])", temperaturesCountry: tempInt)
                    }
                } catch {
                    debugPrint(error)
                }
            }.resume()
        
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch countryNames[indexPath.item] {
        case countryNames[indexPath.item]:
            if let forecastViewController = storyboard.instantiateViewController(identifier: "ForecastViewController") as? ForecastViewController {
                forecastViewController.modalPresentationStyle = .fullScreen
                forecastViewController.myUrl = temperaturesCountry[indexPath.item]
                navigationController?.pushViewController(forecastViewController, animated: false)
            }
        default:
            print("not found")
        }
    }
}

extension UIViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 145, height: 150)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 20
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filterData[indexPath.row]
        
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterData = []
        
        if searchText.isEmpty {
            filterData = allCities
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
        
        for word in allCities {
            if word.uppercased().contains(searchText.uppercased()) {
                filterData.append(word)
            }
        }
        
        forecastCollectionView.reloadData()
        tableView.reloadData()
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        countryNames.append(filterData[indexPath.row])
        
        searchBar.text = nil
        searchBar.endEditing(true)
        tableView.isHidden = true
        
        addCity(name: filterData[indexPath.row])
        setupCollectionView()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.coordinates = locations.last?.coordinate
        locations.last?.fetchCityAndCountry(completion: { ( city, country, error) in
            
            self.countryNames.insert(city!, at: 0)
            self.temperaturesCountry.insert(URL(string:"https://api.weatherapi.com/v1/forecast.json?key=e5c76c2a09fa483da4e65137222306&q=\(city!)&days=7")!, at: 0)

            self.locationManager.delegate = nil
            self.setupCollectionView()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
