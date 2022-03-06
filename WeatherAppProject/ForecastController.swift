//
//  ForecastController.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 23.01.22.
//

import UIKit
import CoreLocation
import DynamicBlurView

class ForecastController: UIViewController {
    
    @IBOutlet var errorView: ErrorView!
    @IBOutlet var gradientView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    var blurView: DynamicBlurView!
    var locationManager: CLLocationManager!
    var forecastDays: [String] = [String]()
    var headerModels: [String : HeaderModel] = [:]
    let forecastService: ForecastService = ForecastService()
    var forecastInformation: [String : [ForecastModel]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance.backgroundEffect = nil
        tabBarController?.tabBar.standardAppearance.backgroundEffect = nil
        
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        loadingIndicator.layer.zPosition = 1
        errorView.setDelegate(delegate: self)
        
        registerCells()
        createBlurView()
        showElements()
    
    }
    
    func showElements(){
        loadingIndicator.startAnimating()
        blurView.isHidden = false
        
        refreshButton.isEnabled = false
        
        if locationManager.authorizationStatus == .authorizedWhenInUse{
            locationManager.requestLocation()
        }else{
            blurView.isHidden = true
            tableView.isHidden = true
            
            errorView.isHidden = false
            errorView.setInformation(text: "App requires location access")
            
            loadingIndicator.stopAnimating()
            refreshButton.isEnabled = true
        }
    }
    
    @IBAction func reload(){
        showElements()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.blurView?.frame = self.gradientView.bounds
        }
    }
    
    func fetchData(lat: Double, lon: Double){
        forecastService.loadForecast(lat: lat, lon: lon, completion: {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.forecastDays.removeAll()
                    self?.forecastInformation.removeAll()
                    for elem in data.list{
                        self?.fillDictionary(date: elem.dt_txt, iconName: elem.weather[0].icon, temp: "\(Int(elem.main.temp))", desc: elem.weather[0].description, city: data.city.name, humidity: Int(elem.main.humidity), windSpeed: elem.wind.speed, cloudiness: elem.clouds.all)
                    }
                    self?.tableView.reloadData()
                    
                    self?.blurView.isHidden = true
                    self?.errorView.isHidden = true
                    
                    self?.loadingIndicator.stopAnimating()
                    self?.tableView.isHidden = false
                    
                    self?.refreshButton.isEnabled = true
                    
                case .failure(let error):
                    self?.blurView.isHidden = true
                    self?.tableView.isHidden = true
                    
                    self?.loadingIndicator.stopAnimating()
                    
                    self?.errorView.setInformation(text: error.errorDescription)
                    self?.errorView.isHidden = false
                    
                    self?.refreshButton.isEnabled = true
                }
            }}
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        blurView?.frame = gradientView.bounds
    }
    
    func fillDictionary(date: String, iconName: String, temp: String, desc: String, city: String, humidity: Int, windSpeed: Double, cloudiness: Int){
        let weekday = getDay(txt: date)
        if !forecastDays.contains(weekday){
            forecastDays.append(weekday)
        }
        
        let headerModel: HeaderModel = HeaderModel(text: weekday, section: -1, isExpanded: true, expandDelegate: self)
        
        headerModels[weekday] = headerModel
        
        let time = String((date.components(separatedBy: " ")[1]).prefix(5))
        
        
        let newModel: ForecastModel = ForecastModel(city: city, time: time, iconName: iconName, isExpanded: false, humidity: humidity, windSpeed: windSpeed, cloudiness: cloudiness, description: desc, temperature: "\(temp)°C")
        
        if forecastInformation[weekday] == nil{
            let newArray: [ForecastModel] = [newModel]
            forecastInformation[weekday] = newArray
        }else{
            forecastInformation[weekday]!.append(newModel)
        }
    }
    
    func createBlurView(){
        blurView = DynamicBlurView(frame: gradientView.bounds)
        blurView!.blurRadius = 10
        blurView!.trackingMode = .common
        
        gradientView.addSubview(blurView!)
        blurView!.isHidden = true
    }
    
    func registerCells(){
        tableView.register(
            UINib(nibName: "ForecastCell", bundle: nil),
            forCellReuseIdentifier: "ForecastCell"
        )
        
        tableView.register(
            UINib(nibName: "WeekdayHeader", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "WeekdayHeader"
        )
    }
    
    func getDay(txt: String) -> String{
        let components = txt.components(separatedBy: " ")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: TimeZone.current.abbreviation()!)
        
        guard let date = formatter.date(from: components[0]) else {
            return ""
        }

        let result = formatter.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
        
        return result
    }

}

extension ForecastController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return forecastInformation[forecastDays[indexPath.section]]![indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let weekday = forecastDays[section]
        if headerModels[weekday]!.isExpanded{
            return forecastInformation[weekday]!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "WeekdayHeader")

        if let MyHeader = header as? WeekdayHeader{
            headerModels[forecastDays[section]]!.section = section
            let currentModel: HeaderModel = headerModels[forecastDays[section]]!
            MyHeader.configure(model:  currentModel)
        }

        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return forecastInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath)
        if let MyCell = cell as? ForecastCell {
            let weekday = forecastDays[indexPath.section]
            MyCell.configure(model: forecastInformation[weekday]![indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shareAction = UIContextualAction(style: .normal, title: "Share", handler: { _,_,_ in
            
            let cell = self.forecastInformation[self.forecastDays[indexPath.section]]![indexPath.row]
            let temperature = cell.temperature
            
            let textToShare: String = "There is \(temperature) in \(cell.city) at \(cell.time) on \(self.forecastDays[indexPath.section])."
            
            let activityController: UIActivityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)

            
            self.present(activityController, animated: true, completion: {})
        })
        
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        return UISwipeActionsConfiguration(actions: [shareAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        forecastInformation[forecastDays[indexPath.section]]![indexPath.row].isExpanded.toggle()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}


extension ForecastController: CLLocationManagerDelegate{
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coord = manager.location?.coordinate
        fetchData(lat: Double(coord?.latitude ?? 0), lon: Double(coord?.longitude ?? 0))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        showElements()
    }
}


extension ForecastController: ReloadDelegate, ExpandDelegate{
    
    func clickExpandCollapse(section: Int) {
        
        var deletePaths = [IndexPath]()
        for i in 0...forecastInformation[forecastDays[section]]!.count - 1{
            let indexPath = IndexPath(row: i, section: section)
            deletePaths.append(indexPath)
        }
        
        tableView.beginUpdates()
        headerModels[forecastDays[section]]!.isExpanded.toggle()
        
        if headerModels[forecastDays[section]]!.isExpanded{
            tableView.insertRows(at: deletePaths, with: .fade)
        }else{
            tableView.deleteRows(at: deletePaths, with: .fade)
        }
        tableView.endUpdates()
    }
    
    
    func reloadInfo() {
        reload()
    }
}
