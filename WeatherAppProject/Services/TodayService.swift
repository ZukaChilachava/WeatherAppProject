//
//  TodayService.swift
//  WeatherAppProject
//
//  Created by Zuka Chilachava on 23.01.22.
//

import Foundation

class TodayService{
    private let apiKey: String = "6b9580b48e4a004ad818cd060d9fe0f3"
    private var components: URLComponents = URLComponents()
    
    init(){
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
    }

    func loadTodayForecast(lat: Double, lon: Double, completion: @escaping (Result<TodayResponse, ServiceError> ) -> Void){
        let parameters = ["lat": String(lat), "lon" : String(lon), "units": "metric", "appid": apiKey]
        
        components.queryItems = parameters.map{ key, value in
            return URLQueryItem(name: key, value: value)
        }
        
        if let url = components.url{
            let request = URLRequest(url: url)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error in
                if error != nil{
                    completion(.failure(ServiceError.badConnection))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {

                    if httpResponse.statusCode == 200, let data = data {
                        let decoder = JSONDecoder()
                        do{
                            let result = try decoder.decode(TodayResponse.self, from: data)
                            completion(.success(result))
                        }catch{
                            completion(.failure(ServiceError.decodingError))
                        }
                    }else if httpResponse.statusCode == 401{
                        completion(.failure(ServiceError.invalidAPIKey))
                    }else if httpResponse.statusCode == 429{
                        completion(.failure(ServiceError.subscriptionLimit))
                    }else if httpResponse.statusCode == 404{
                        completion(.failure(ServiceError.wrongLocation))
                    }else{
                        completion(.failure(ServiceError.undefinedError))
                    }
                    
                }else{
                    completion(.failure(ServiceError.badResponse))
                }
                
            })
            
            task.resume()
            
        }else{
            completion(.failure(ServiceError.invalidParameters))
        }
        
    }
}

enum ServiceError: LocalizedError{
    case badConnection
    case badResponse
    case decodingError
    case invalidAPIKey
    case wrongLocation
    case undefinedError
    case subscriptionLimit
    case serverUnavailable
    case invalidParameters
    
    var errorDescription: String {
        switch self {
        case .badConnection:
            return "Bad connection"
        case .badResponse:
            return "Bad response"
        case.subscriptionLimit:
            return "You made more than 60 calls"
        case .wrongLocation:
            return "Wrong location specified"
        case .invalidAPIKey:
            return "Invalid API key or API key unspecified"
        case .decodingError:
            return "Error while decoding json"
        case .serverUnavailable:
            return "Server unavailable, please try again later"
        case.invalidParameters:
            return "Invalid parameters for website URL"
        case.undefinedError:
            return "Cannot indentify error"
        }
    }
}
