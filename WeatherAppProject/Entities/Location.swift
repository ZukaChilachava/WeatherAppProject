//
//  Location.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 06.02.22.
//

import Foundation

struct LocationResponse: Codable{
    let weather: [Weather]
    let main: TemperatureInfo
    let wind: WindInfo
    let clouds: CloudInfo
    let sys: SysInfo
    let name: String
}
