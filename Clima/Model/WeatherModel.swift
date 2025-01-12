//
//  WeatherModel.swift
//  Clima
//
//  Created by Gero Walther on 15/10/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

struct WeatherModel {
    // Properties
    let conditionId: Int
    let cityName: String
    let temperature: Double
    let windSpeed: Double
    let description: String
    let pressure: Int
    let humidity: Int
    let sunrise: Date
    let sunset: Date
    let precipitationChance: Double
    let forecast: [DayForecast]
    
    // Computed Properties
    var tempString: String {
        return String(format: "%.1f°", temperature)
    }
    
    var windSpeedString: String {
        return String(format: "%.1f m/s", windSpeed)
    }
    
    var sunriseString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: sunrise)
    }
    
    var sunsetString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: sunset)
    }
    
    var conditionName: String {
        return WeatherModel.getConditionName(conditionId)
    }
    
    // Static method for getting condition name
    static func getConditionName(_ conditionId: Int) -> String {
        switch conditionId {
        case 200...232: return "cloud.bolt"
        case 300...321: return "cloud.drizzle"
        case 500...531: return "cloud.rain"
        case 600...622: return "cloud.snow"
        case 701...781: return "cloud.fog"
        case 800: return "sun.max"
        case 801...804: return "cloud.bolt"
        default: return "cloud"
        }
    }
}
