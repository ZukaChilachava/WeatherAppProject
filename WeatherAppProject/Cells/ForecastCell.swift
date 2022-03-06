//
//  ForecastCell.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 25.01.22.
//

import UIKit

struct ForecastModel{
    var city: String
    var time: String
    var iconName: String
    var isExpanded: Bool
    var humidity: Int
    var windSpeed: Double
    var cloudiness: Int
    var description: String
    var temperature: String
    
    var height: CGFloat {
        return isExpanded ? 150 : 60
    }
}

class ForecastCell: UITableViewCell {
    
    @IBOutlet var heightConstraintExpanded: NSLayoutConstraint!
    @IBOutlet var heightConstraintCollapsed: NSLayoutConstraint!
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var cloudinessLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var forecastImage: UIImageView!
    @IBOutlet var details: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configure(model: ForecastModel){
        forecastImage.sd_setImage(with: URL(string: "http://openweathermap.org/img/wn/\(model.iconName)@4x.png"), placeholderImage:  UIImage(systemName: "cloud.fill"))
        timeLabel.text = model.time
        descriptionLabel.text = model.description
        temperatureLabel.text = model.temperature
        humidityLabel.text = "\(model.humidity) mm"
        cloudinessLabel.text = "\(model.cloudiness)%"
        windSpeedLabel.text = "\(model.windSpeed) km/h"
        details.isHidden = !model.isExpanded
        
        if model.isExpanded{
            heightConstraintExpanded.priority = UILayoutPriority(999)
            heightConstraintCollapsed.priority = .defaultHigh
        }else{
            heightConstraintExpanded.priority = .defaultHigh
            heightConstraintCollapsed.priority = UILayoutPriority(999)
        }
    }

}
