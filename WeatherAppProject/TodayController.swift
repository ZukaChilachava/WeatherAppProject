//
//  TodayController.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 23.01.22.
//

import UIKit
import CoreLocation
import SDWebImage
import DynamicBlurView

class TodayController: UIViewController {
    
    @IBOutlet var yAxis: NSLayoutConstraint!
    @IBOutlet var fixedWidth: NSLayoutConstraint!
    @IBOutlet var fixedHeight: NSLayoutConstraint!
    @IBOutlet var relativeWidth: NSLayoutConstraint!
    @IBOutlet var relativeHeight: NSLayoutConstraint!
    @IBOutlet var upperHeight: NSLayoutConstraint!
    @IBOutlet var upperHeightHalf: NSLayoutConstraint!
    
    
    @IBOutlet var stack: UIStackView!
    @IBOutlet var stackSpacer: UIView!
    @IBOutlet var gradientView: UIView!
    @IBOutlet var LocationLabel: UILabel!
    @IBOutlet var middleSeperator: UIView!
    @IBOutlet var weatherImage: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var mainInfoStack: UIStackView!
    @IBOutlet var errorComponents: ErrorView!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var cloudView: SecondaryWeatherInfo!
    @IBOutlet var humidityView: SecondaryWeatherInfo!
    @IBOutlet var pressureView: SecondaryWeatherInfo!
    @IBOutlet var windSpeedView: SecondaryWeatherInfo!
    @IBOutlet var directionView: SecondaryWeatherInfo!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    var currentTemp: String?
    var blurView: DynamicBlurView?
    let gradientLayer = CAGradientLayer()
    var locationManager: CLLocationManager!
    let todayService: TodayService = TodayService()
    let directions = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW","N"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        errorComponents.setDelegate(delegate: self)

        createBlurView()
        showElements()
        changeStack()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        changeStack()
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.blurView?.frame = self.gradientView.bounds
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        blurView?.frame = gradientView.bounds
    }
    
    func showElements(){
        blurView!.isHidden = false
        
        
        loadingIndicator.layer.zPosition = 1
        loadingIndicator.startAnimating()
        
        shareButton.isEnabled = false
        refreshButton.isEnabled = false
        
        
        if locationManager.authorizationStatus == .authorizedWhenInUse{
            locationManager.requestLocation()
            
        }else{
            loadingIndicator.stopAnimating()
            
            shareButton.isEnabled = false
            refreshButton.isEnabled = true
            
            stack.isHidden = true
            blurView!.isHidden = true
            
            errorComponents.isHidden = false
            middleSeperator.isHidden = true
            errorComponents.setInformation(text: "App requires location access")
        }
    }
    
    func createBlurView(){
        blurView = DynamicBlurView(frame: gradientView.bounds)
        blurView!.blurRadius = 10
        blurView!.trackingMode = .common
        
        gradientView.addSubview(blurView!)
        blurView!.isHidden = true
    }
    
    @IBAction func reload(){
        showElements()
    }
    
    @IBAction func share(){
        let textToShare: String = "There is \(currentTemp!) degrees celsius in \(self.LocationLabel.text!)."
        
        let activityController: UIActivityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        
        present(activityController, animated: true, completion: {})
    }
    
    func changeStack(){
        if UIDevice.current.orientation.isLandscape{
            fixedWidth.priority = UILayoutPriority(999)
            relativeWidth.priority = .defaultHigh

            fixedHeight.priority = .defaultHigh
            relativeHeight.priority = UILayoutPriority(999)
            
            upperHeight.priority = .defaultHigh
            upperHeightHalf.priority = UILayoutPriority(999)
            
            yAxis.constant = 0
            
            stackSpacer.isHidden = true
            stack.axis = .horizontal
        }else{
            fixedWidth.priority = .defaultHigh
            relativeWidth.priority = UILayoutPriority(999)

            fixedHeight.priority = UILayoutPriority(999)
            relativeHeight.priority = .defaultHigh
            
            upperHeight.priority = UILayoutPriority(999)
            upperHeightHalf.priority = .defaultHigh
            
            yAxis.constant = -5
            
            stackSpacer.isHidden = false
            stack.axis = .vertical
        }
    }
    
    func loadForecast(lat: Double, lon: Double){
        todayService.loadTodayForecast(lat: lat, lon: lon, completion: {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let address = data.name
                    let country = data.sys.country
                    let temperature = data.main.temp
                    let weather = data.weather[0].main
                    let iconName = data.weather[0].icon
                    let pressure = data.main.pressure
                    let humidity = data.main.humidity
                    let windSpeed = data.wind.speed
                    let degrees = data.wind.deg
                    let cloudiness = data.clouds.all
                    
                    self?.LocationLabel.text = "\(address), \(country)"
                    self?.temperatureLabel.text = "\(Int(temperature))°C | \(weather)"
                    self?.currentTemp = "\(Int(temperature))"
                    
                    self?.weatherImage.sd_setImage(with: URL(string: "http://openweathermap.org/img/wn/\(iconName)@4x.png"), placeholderImage:  UIImage(systemName: "cloud.fill"))
                    
                    
                    let index = Int(degrees.truncatingRemainder(dividingBy: 360) / 22.5)
                    let direction: String = (self?.directions[index])!
                    
                    self?.cloudView.setInformation(text: "\(cloudiness)%", info: "cloud")
                    self?.humidityView.setInformation(text: "\(humidity) mm", info: "humidity")
                    self?.pressureView.setInformation(text: "\(pressure) hPa", info: "pressure")
                    self?.windSpeedView.setInformation(text: "\(windSpeed) km/h", info: "wind")
                    self?.directionView.setInformation(text: "\(direction)", info: "direction")
                    
                    self?.loadingIndicator.stopAnimating()
                    self?.stack.isHidden = false
                    self?.errorComponents.isHidden = true
                    self?.blurView!.isHidden = true
                    
                    self?.shareButton.isEnabled = true
                    self?.refreshButton.isEnabled = true
                    self?.middleSeperator.isHidden = false
                    
                case .failure(let error):
                    let description = error.errorDescription
                    self?.errorComponents.setInformation(text: description)
                    
                    self?.loadingIndicator.stopAnimating()
                    
                    self?.errorComponents.isHidden = false
                    self?.stack.isHidden = true
                    self?.blurView!.isHidden = true
                    
                    self?.shareButton.isEnabled = false
                    self?.refreshButton.isEnabled = true
                    self?.middleSeperator.isHidden = true
                }
            }
        })
    }
    
}

extension TodayController: CLLocationManagerDelegate{
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coord = manager.location?.coordinate
        loadForecast(lat: Double(coord?.latitude ?? 0), lon: Double(coord?.longitude ?? 0))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        showElements()
    }
}


extension TodayController: ReloadDelegate{
    func reloadInfo() {
        self.reload()
    }
}
