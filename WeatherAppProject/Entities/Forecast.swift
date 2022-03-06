//
//  Forecast.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 25.01.22.
//

import Foundation


struct ForecastResponse: Codable{
    let list: [Day]
    let city: City
}

struct City: Codable{
    let name: String
}

struct Day: Codable{
    let main: Temperature
    let weather: [WeatherDescription]
    let clouds: Clouds
    let wind: Wind
    let dt_txt: String
}

struct Clouds: Codable{
    let all: Int
}

struct Wind: Codable{
    let speed: Double
}

struct Temperature: Codable{
    let temp: Double
    let humidity: Double
}

struct WeatherDescription: Codable{
    let description: String
    let icon: String
}
