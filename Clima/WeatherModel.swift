//
//  WeatherModel.swift
//  Clima
//
//  Created by Gero Walther on 15/10/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

struct WeatherModel {
// stored properties
    let conditionId: Int
    let cityName: String
    let temperature: Double

    let windSpeed: Double
    let description: String
    
// computed property ; has to be var bc it changes based on the computation
    var tempString: String {
        return String(format: "%.1f", temperature)
    }
    var windSpeedString: String {
        return String(format: "%.1f", windSpeed)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizze"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }

}
