//
//  MultipleLocations.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 06.02.22.
//

import UIKit
import CoreLocation
import DynamicBlurView

class MultipleLocations: UIViewController{
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    var blurView: DynamicBlurView!
    var arrayLock: NSLock = NSLock()
    var fetchGroup: DispatchGroup = DispatchGroup()
    var currentWeather: TodayService = TodayService()
    var modelArray: [LocationsModel] = [LocationsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance.backgroundEffect = nil
        tabBarController?.tabBar.standardAppearance.backgroundEffect = nil
        
        loadingIndicator.layer.zPosition = 1
        
        registerCells()
        registerLongPress()
        
        createBlurView()
        loadLocations()
    }
    
    func registerLongPress(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteLocation))
        longPressGesture.minimumPressDuration = 1
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func deleteLocation(longPressGesture: UILongPressGestureRecognizer){
        let location = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: location)
        
        if let indexPath = indexPath{
            
            let deleteAlert = UIAlertController(title: "Do you want to delete this cell?", message: "", preferredStyle: .alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                self.tableView.beginUpdates()
                let userDefaultName = self.modelArray[indexPath.row].systemName
                self.modelArray.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.endUpdates()
                let currentArray = UserDefaults.standard.stringArray(forKey: "locations")
                UserDefaults.standard.set(currentArray!.filter({return $0 != userDefaultName}), forKey: "locations")
            }))
            
            if(presentedViewController == nil) {
                self.present(deleteAlert, animated: true, completion: {})
            }
        }
    }
    
    func registerCells(){
        tableView.register(
            UINib(nibName: "LocationsCell", bundle: nil),
            forCellReuseIdentifier: "LocationsCell"
        )
    }
    
    func loadLocations(){
        let locationsArray: [String] = UserDefaults.standard.stringArray(forKey: "locations") ?? [String]()
        fetchGroup = DispatchGroup()
        
        loadingIndicator.startAnimating()
        blurView.isHidden = false
        refreshButton.isEnabled = false
        
        modelArray.removeAll()
        
        for name in locationsArray{
            fetchGroup.enter()
            loadLocation(locationName: name)
        }
        groupNotify()
    }
    
    func groupNotify(){
        fetchGroup.notify(queue: .main){
            self.refreshButton.isEnabled = true
            self.blurView.isHidden = true
            self.loadingIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    func loadLocation(locationName: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationName) {
            placemarks, error in
            
            if(error == nil){
                let placemark = placemarks?.first
                let lat = placemark?.location?.coordinate.latitude
                let lon = placemark?.location?.coordinate.longitude
                
                self.currentWeather.loadTodayForecast(lat: lat!, lon: lon!, completion: {[weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                            case .success(let data):
                            let model = LocationsModel(city: data.name, country: data.sys.country,iconName: data.weather[0].icon, temperature: Int(data.main.temp), systemName: locationName)
                            self?.arrayLock.lock()
                            self?.modelArray.append(model)
                            self?.arrayLock.unlock()
                            
                            self?.fetchGroup.leave()

                            case .failure(let error):
                            
                            if(self?.presentedViewController == nil){
                                self?.incorrectResponseNotification(errorMessage: error.errorDescription)
                            }
                            
                            self?.fetchGroup.leave()
                        }
                        
                    }
                })
            }else{
                if(self.presentedViewController == nil){
                    self.incorrectResponseNotification(errorMessage: "Too many Requests, some locations won't show up")
                }
                self.fetchGroup.leave()
            }
        }
    }
    
    func createBlurView(){
        blurView = DynamicBlurView(frame: gradientView.bounds)
        blurView!.blurRadius = 10
        blurView!.trackingMode = .common
        
        gradientView.addSubview(blurView!)
        blurView!.isHidden = true
    }
    
    
    @IBAction func addCity(){
        let alertController = UIAlertController(title: "New Location", message: "", preferredStyle: .alert)
        
        var locationName: UITextField!
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Location Name"
            locationName = textField
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {action in
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationName.text!) {
                placemarks, error in
                if(error != nil){
                    let incorrectLocationNameAlert = UIAlertController(title: "Location not saved", message: "", preferredStyle: .alert)
                    
                    incorrectLocationNameAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    
                    self.present(incorrectLocationNameAlert, animated: true, completion:nil)
                }else{
                    var newArray = UserDefaults.standard.stringArray(forKey: "locations") ?? [String]()
                    newArray.append(locationName.text!)
                    UserDefaults.standard.set(newArray, forKey: "locations")
                    
                    let placemark = placemarks?.first
                    let lat = placemark?.location?.coordinate.latitude
                    let lon = placemark?.location?.coordinate.longitude
                    
                    self.currentWeather.loadTodayForecast(lat: lat!, lon: lon!, completion: {[weak self] result in
                        DispatchQueue.main.async {
                            switch result {
                                case .success(let data):
                                let model = LocationsModel(city: data.name, country: data.sys.country,iconName: data.weather[0].icon, temperature: Int(data.main.temp), systemName: locationName.text!)
                                
                                self?.tableView.beginUpdates()
                                self?.modelArray.append(model)
                                let lastElem = IndexPath(row: (self?.modelArray.count)! - 1, section: 0)
                                self?.tableView.insertRows(at: [lastElem], with: .fade)
                                self?.tableView.endUpdates()
                                
                                case .failure(let error):
                                self?.incorrectResponseNotification(errorMessage: error.errorDescription)
                            }
                            
                        }
                    })
                }
            }
        })
        
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: {})
    }
    
    @IBAction func refresh(){
        loadLocations()
    }
    
    func incorrectResponseNotification(errorMessage: String){
        let serviceErrorAlert = UIAlertController(title: errorMessage, message: "", preferredStyle: .alert)
        
        serviceErrorAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.present(serviceErrorAlert, animated: true, completion:nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.blurView?.frame = self.gradientView.bounds
        }
    }
}

extension MultipleLocations: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationsCell", for: indexPath)
        if let MyCell = cell as? LocationsCell {
            let model = modelArray[indexPath.row]
            MyCell.configure(model: model)
        }
        
        return cell
    }
}
