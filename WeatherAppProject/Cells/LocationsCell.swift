//
//  LocationsCell.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 06.02.22.
//

import UIKit

struct LocationsModel{
    var city: String
    var country: String
    var iconName: String
    var temperature: Int
    var systemName: String
}

class LocationsCell: UITableViewCell {

    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var forecastItem: UIView!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var weatherImage: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        forecastItem.layer.cornerRadius = 20
        self.selectionStyle = .none
    }
    
    func configure(model: LocationsModel){
        weatherImage.sd_setImage(with: URL(string: "http://openweathermap.org/img/wn/\(model.iconName)@4x.png"), placeholderImage:  UIImage(systemName: "cloud.fill"))
        
        cityLabel.text = model.city
        countryLabel.text = model.country
        temperatureLabel.text = "\(model.temperature)°C"
    }
    
}
