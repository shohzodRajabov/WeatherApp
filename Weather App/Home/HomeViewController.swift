//
//  HomeViewController.swift
//  Weather App
//
//  Created by Shohzod Rajabov on 23/02/22.
//

import UIKit
import SnapKit
import MapKit
import CoreLocation
import ProgressHUD
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, SkeletonDisplayable {
    
    
    
    let searchBar = UISearchBar()
    let tableview = UITableView()
    var refreshControl: UIRefreshControl!
    let locationManager = CLLocationManager()
    var locVal: CLLocationCoordinate2D!
    var oldLocation:CLLocation? //  = CLLocation(latitude: 0, longitude: 0)

    var citiesJson = [City]()
    var resultArr = [City]()
    var fullWeather: WeatherFull?
    var currentCityName: CurrentCityName?
    
    var isSearching = false
    var isWeekly = true
    var skeletonIsWorked = true
    let type = "metric"
    var lon: Double = 0.0
    var lat: Double = 0.0
    var cityName: String = ""
    let extrow = 3
    
    let bgColor = UIColor(red: 52/256, green: 109/256, blue: 179/256, alpha: 1)
    
    
    let defList = [Definition(defText: "Current temprature", iconName: "temp"),
                   Definition(defText: "Feels like temprature", iconName: "feels_like"),
                   Definition(defText: "Atmospheric pressure at the moment", iconName: "pressure"),
                   Definition(defText: "Current air humidity", iconName: "humidity"),
                   Definition(defText: "Wind speed", iconName: "wind"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor

        
        ProgressHUD.show()
        ProgressHUD.colorAnimation = bgColor
        
        initSubviews()
        embedSubviews()
        addSubviewsConstraints()
        configureSearchBar()
        
        
        setLocationManager()
        parse()
       
    }
    
    
    @objc func refresh(_ sender: Any) {
        refreshControl.endRefreshing()
    }
    
}

//  CLLocationManagerDelegate:
extension HomeViewController: CLLocationManagerDelegate {

    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality, placemarks?.first?.country, error)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = manager.location else { return }
        fetchCityAndCountry(from: location) { city, country, error in
            guard let city = city, error == nil else { return }
            self.cityName = city
        }
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            if oldLocation == nil {
                oldLocation = location
                getInfo(lon: lon, lat: lat)
            }
            if location.distance(from: oldLocation ?? CLLocation()) > 500 {
                oldLocation = location
                getInfo(lon: lon, lat: lat)
            }
        }
    }
    
    func setLocationManager() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
}


//   init Function:
extension HomeViewController {
   
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.endEditing(true)
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.textColor = .black
        searchBar.placeholder = " write city name"
        searchBar.searchTextField.leftView?.tintColor = .black
        self.searchBar.delegate = self
       
        navigationController?.navigationBar.backgroundColor = bgColor
        navigationItem.title = "Open Weather Map"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.barTintColor = bgColor
//        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .black
        showSearchBarButton(shouldShow: true)
    }

    func initSubviews() {
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "loading...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    
        tableview.addSubview(refreshControl)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = .clear
        tableview.separatorStyle = .none
        tableview.register(HomeCell.self, forCellReuseIdentifier: "HomeCell")
        tableview.register(InfoCell.self, forCellReuseIdentifier: "InfoCell")
        tableview.register(HourlyCell.self, forCellReuseIdentifier: "HourlyCell")
        tableview.register(WeeklyCell.self, forCellReuseIdentifier: "WeeklyCell")
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func embedSubviews() {
        view.addSubview(tableview)
    }
    
    func addSubviewsConstraints() {
        tableview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

//  TableViewDelegate:
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            if resultArr.count == 0 {
                return 1
            }
            return resultArr.count
        }
        return  defList.count+extrow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if skeletonIsWorked {
            showSkeleton()
        }
        
        if isSearching {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
            if resultArr.count == 0 {
                cell.textLabel?.text = "City not found!"
                cell.selectionStyle = .none
                return cell
            }
            cell.textLabel?.text = resultArr[indexPath.row].name
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .black
            return cell
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell") as! HomeCell
            cell.backgroundColor = .clear
            cell.initCityName(cityName)
            cell.initDatas(self.fullWeather ?? nil)
            
            cell.selectionStyle = .none
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyCell") as! WeeklyCell
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HourlyCell") as! HourlyCell
          
            cell.backgroundColor = .clear
            let q:[Hourly] = [Hourly.init(isCustom: true),Hourly.init(isCustom: true),Hourly.init(isCustom: true)]
            cell.items = fullWeather?.hourly ?? q
            cell.timezone = fullWeather?.timezone_offset ?? 0
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") as! InfoCell
        cell.backgroundColor = .clear
        cell.initDatas(self.fullWeather ?? nil, index: indexPath.row-extrow)
        cell.initDef(defList[indexPath.row-extrow])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 && !isSearching{
            let controller = WeeklyViewController()
            self.navigationController?.pushViewController(controller, animated: true)
            controller.fullWeather = self.fullWeather
            controller.title = cityName
        }
        if isSearching && resultArr.count > 0{
            searchBar.text = resultArr[indexPath.row].name
            isSearching = false
            lon = resultArr[indexPath.row].coord?.lon ?? 0.0
            lat = resultArr[indexPath.row].coord?.lat ?? 0.0
            cityName = resultArr[indexPath.row].name ?? ""
            getInfo(lon: lon, lat: lat)
            searchBar.showsCancelButton = isSearching
            navigationItem.titleView = isSearching ? searchBar : nil
            showSearchBarButton(shouldShow: !isSearching)
            searchBar.text = ""
        }
        tableview.reloadData()
    }
 
}

//      UISearchBarDelegate Metods

extension HomeViewController: UISearchBarDelegate {
    
    @objc func handleShowSearchBar () {
        search(shouldShow: true)
        searchBar.becomeFirstResponder()
    }
   
    func showSearchBarButton(shouldShow: Bool) {
        if shouldShow {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleShowSearchBar))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func search(shouldShow: Bool) {
        showSearchBarButton(shouldShow: !shouldShow)
        isSearching = !isSearching
        searchBar.showsCancelButton = shouldShow
        navigationItem.titleView = shouldShow ? searchBar : nil
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search(shouldShow: false)
        tableview.reloadData()
        searchBar.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultArr = citiesJson.filter({
         $0.name?.range(of: searchText, options: .caseInsensitive) != nil
        })
        tableview.reloadData()
    }
    
}

//      API & JSON Metods:
extension HomeViewController {
    
    func parse() {
        guard let path = Bundle.main.path(forResource: "city.list", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        if let data = try? Data(contentsOf: url) {
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: AnyObject]] {
                    for js in json{
                        let obj = City.init(js)
                        citiesJson.append(obj)
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
    }
    
//   Alamofire
    func getInfo(lon:Double, lat: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?"
        let parameters = ["lat": "\(lat)",
                          "lon": "\(lon)",
                          "units" : "\(type)",
                          "exclude" : "alerts",
                          "appid" : "925d96fe3a7e5e865fc3b8dfecde744a"]
        let requestId =  makeIdentifier()
        let request = AF.request(urlString, parameters: parameters).responseJSON { response in
            ProgressHUD.dismiss()
            
            if let responseData = response.data{
                do {
                    if let json = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String:AnyObject]{
                        let obj = WeatherFull.init(json)
                        self.fullWeather = obj
                        self.tableview.reloadData()
                        DispatchQueue.main.async {
                            self.hideSkeleton()
                            self.skeletonIsWorked = false
                        }
                    }
                    
                } catch _ as NSError {
                    
                }
            }
            self.logResponse(with: requestId, response: response)
        }
        DispatchQueue.main.async {
            self.logRequest(request: request.request, with: requestId)
        }
    }
    
    
//      URLSession
//    func getInfo(lon:Double, lat: Double){
//        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&units=\(type)&exclude=alerts&appid=925d96fe3a7e5e865fc3b8dfecde744a") else{ return }
//        let session = URLSession.shared
//        session.dataTask(with: url) { [self] (data, response, error )in
//            guard let data = data else { return }
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
//                    let obj = WeatherFull.init(json)
//                    self.fullWeather = obj
//                    DispatchQueue.main.async {
//                        self.tableview.reloadData()
//                        //dismiss hud
//                        ProgressHUD.dismiss()
//                    }
//                }
//            }
//            catch {
//                print("ERROR: \(error)")
//            }
//        } .resume()
//    }
    
    
    
}

//  Print response & request
extension HomeViewController {
    
    
    private func logRequest(request: URLRequest?,
                        with identifier: String) {
            #if DEBUG
            print("\n\n")
            print("SEND: >>>>")
            print(identifier)
            print(request?.url?.absoluteString ?? "")
            print(request?.httpMethod ?? "")
            print(JSON(request?.allHTTPHeaderFields ?? [:]))
            if let body = request?.httpBody{
                let bodyJson = JSON(body as Any)
                if bodyJson.type != .null {
                    print(bodyJson)
                } else {
                    print(String(data: body, encoding: .utf8) ?? "")
                }
            }
            //print(JSON(request?.httpBody as Any))
            #endif
        }
        
        private func logResponse(with identifier: String, response: AFDataResponse<Any>) {//DataResponse<Any>
            #if DEBUG
            var responseResult: Any = ""
            if let error = response.error {
                responseResult = error.localizedDescription
            } else {
                responseResult = response.data ?? ""
            }
            print("\n\n")
            print("RECV: <<<<")
            print(identifier)
            print(response.response?.statusCode ?? 0)
            print(JSON(responseResult))
            #endif
        }
        
        private func makeIdentifier() -> String {
            let currentDate = Date()
            return "\(currentDate.timeIntervalSince1970)"
        }
    
    
}
