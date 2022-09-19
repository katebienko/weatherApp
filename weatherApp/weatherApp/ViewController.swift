import UIKit
import Foundation
import CoreLocation

class ViewController: UIViewController {
    
    let documentFolderURL: URL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    lazy var jsonFolderURL: URL = documentFolderURL.appendingPathComponent("jsons")
    
    private var locationManager = CLLocationManager()
    private var coordinates: CLLocationCoordinate2D?
    
    let decoder = JSONDecoder() // превращает данные в объект
    let encoder = JSONEncoder() // превращает объект в данные
    
    var isConnection: Bool = UserDefaults.standard.object(forKey: "isConnection") as? Bool ?? true

    var cityNames: [String] = UserDefaults.standard.stringArray(forKey: "cityNamesKey") ?? []
    var pathsCitiesJSON: [URL] = []
    var urlsCities: [URL] = []
    
    var allCitiesInJSON: [String] = []
    var filteredName: [String]!
    
    @IBOutlet private var bgView: UIView!
    @IBOutlet private weak var forecastCollectionView: UICollectionView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "isConnection") as? Bool == false {
            searchBar.isHidden = true
        } else {
            searchBar.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FileManager.default.fileExists(atPath: jsonFolderURL.path) == false {
            try? FileManager.default.createDirectory(at: jsonFolderURL, withIntermediateDirectories: false)
        }
        
        backgroundView()
        checkConnection()
        loadCitiesForSearchJSON()
     //   deleteSpacing()
        tableViewSettings()
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
    
    private func getPathsToJSON() {
            let filesName = try? FileManager.default.contentsOfDirectory(atPath: jsonFolderURL.path)

            for jsonFile in filesName! {
                let fileURL = self.jsonFolderURL.appendingPathComponent("\(jsonFile)")
                
                pathsCitiesJSON.append(fileURL)
            }
    }
    
    private func saveCityJSON(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data)
        let forecastResponse = try? JSONDecoder().decode(ForecastsResponse.self, from: data)
        
        do {
            let fileURL = jsonFolderURL.appendingPathComponent("savedCities\(String(describing: forecastResponse?.location.name)).json")
            //print(fileURL.path)

            try JSONSerialization.data(withJSONObject: json!, options: .prettyPrinted).write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    private func checkConnection() {
        if Reachability.isConnectedToNetwork() {
            isConnection = true
            searchBar.isHidden = false
            
            setupCollectionView()

            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.distanceFilter = 1
        }
        else {
            isConnection = false
            
            let alert = UIAlertController(title: "Internet Connection is not Available!", message: "Do you want to load last data?", preferredStyle: UIAlertController.Style.alert)
                
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [] (action) in
            }))
            
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [self] (action) in
                searchBar.isHidden = true
                
                getPathsToJSON()
                setupCollectionView()
            }))
                
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func tableViewSettings() {
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        filteredName = allCitiesInJSON
    }

    private func setupCollectionView() {
        let key = CitiesCollectionViewCell.reuseIdentifier
        
        forecastCollectionView.register(UINib(nibName: key, bundle: nil), forCellWithReuseIdentifier: key)
        forecastCollectionView.dataSource = self
        forecastCollectionView.delegate = self
        forecastCollectionView.reloadData()
    }
    
    private func addLinkCityToArray(name: String) {
        let newString = name.replacingOccurrences(of: " ", with: "%20")
        urlsCities.append(URL(string:"https://api.weatherapi.com/v1/forecast.json?key=e5c76c2a09fa483da4e65137222306&q=\(newString)&days=7")!)
    }
    
    private func loadCitiesForSearchJSON() {
        if let path = Bundle.main.path(forResource: "json_file", ofType: nil) {
            let url = URL(fileURLWithPath: path)
            
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data)
                let arrayOfDicts = json as? [[String: Any]] ?? []
               
                for dict in arrayOfDicts {
                    if let names = dict["name"] as? String {
                        allCitiesInJSON.append(names)
                    }
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cityNames.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CitiesCollectionViewCell.reuseIdentifier, for: indexPath) as? CitiesCollectionViewCell else {
            fatalError()
        }
        
        var url: URL
        if isConnection == true {
            url = urlsCities[indexPath.item]
        } else {
            url = pathsCitiesJSON[indexPath.item]
        }
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else { return }
            
            if self.isConnection {
                self.saveCityJSON(data: data)
            }
            
            do {
                let forecastResponse = try JSONDecoder().decode(ForecastsResponse.self, from: data)
                
                DispatchQueue.main.sync { [] in
                    cell.setup(
                        cityNames: "\(forecastResponse.location.name)",
                        cityTemperatures: String(Int(forecastResponse.current.temp_c)) + "°"
                    )
                }
            }
            catch { debugPrint(error) }
        }.resume()

        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let forecastViewController = storyboard.instantiateViewController(identifier: "ForecastViewController") as? ForecastViewController {
            
            forecastViewController.modalPresentationStyle = .fullScreen
            
            if isConnection == true {
                forecastViewController.myUrl = urlsCities[indexPath.item]
            } else {
                forecastViewController.myUrl = pathsCitiesJSON[indexPath.item]
            }
            
            navigationController?.pushViewController(forecastViewController, animated: true)
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

        return filteredName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = filteredName[indexPath.row]
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredName = []
        
        if searchText.isEmpty {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
        
        for city in allCitiesInJSON {
            if city.uppercased().contains(searchText.uppercased()) {
                //added cities witch contain letters to array
                filteredName.append(city)
            }
        }
        
        tableView.reloadData()
        forecastCollectionView.reloadData()
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //added chosen city and city's link to server to arrays
        cityNames.append(filteredName[indexPath.row])
        addLinkCityToArray(name: filteredName[indexPath.row])
        
        UserDefaults.standard.set(cityNames, forKey: "cityNamesKey")
        
        searchBar.text = nil
        searchBar.endEditing(true)
        tableView.isHidden = true
        
        forecastCollectionView.reloadData()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinates = locations.last?.coordinate
        
        locations.last?.fetchCityAndCountry(completion: { [self] ( city, country, error) in
            cityNames.append(city!)
            urlsCities.append(URL(string:"https://api.weatherapi.com/v1/forecast.json?key=e5c76c2a09fa483da4e65137222306&q=\(city!)&days=7")!)
            
            cityNames.removeDuplicates()
            urlsCities.removeDuplicates()
            
            UserDefaults.standard.set(cityNames, forKey: "cityNamesKey")
            
            forecastCollectionView.reloadData()
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

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
