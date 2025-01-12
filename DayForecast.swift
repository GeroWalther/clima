//
//  DayForecast.swift
//  Clima
//
//  Created by Gero Walther on 12/1/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//


import Foundation

struct DayForecast {
    let date: Date
    let maxTemp: Double
    let minTemp: Double
    let conditionId: Int
    let precipitationChance: Double
    
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var maxTempString: String {
        return String(format: "%.1f°", maxTemp)
    }
    
    var minTempString: String {
        return String(format: "%.1f°", minTemp)
    }
    
    var precipitationString: String {
        return String(format: "%.0f%%", precipitationChance * 100)
    }
}
