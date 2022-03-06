//
//  Today.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 23.01.22.
//

import Foundation

struct TodayResponse: Codable{
    let weather: [Weather]
    let main: TemperatureInfo
    let wind: WindInfo
    let clouds: CloudInfo
    let sys: SysInfo
    let name: String
}

struct Weather: Codable{
    let main: String
    let icon: String
}

struct TemperatureInfo: Codable{
    let temp: Double
    let pressure: Double
    let humidity: Double
}

struct WindInfo: Codable{
    let speed: Double
    let deg: Double
}

struct CloudInfo: Codable{
    let all: Int
}

struct SysInfo: Codable{
    let country: String
}
