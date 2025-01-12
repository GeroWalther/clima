//
//  WeatherManager.swift
//  Clima
//
//  Created by Gero Walther on 13/10/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

@MainActor
class WeatherManager: ObservableObject {
    @Published var weather: WeatherModel?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let weatherUrl = "https://api.openweathermap.org/data/2.5/forecast?appid=32e8ebacafb05c5146276b7ff2ed55bb&units=metric"
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        Task {
            await performRequest(with: urlString)
        }
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        Task {
            await performRequest(with: urlString)
        }
    }
    
    private func performRequest(with urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
            weather = createWeatherModel(from: decodedData)
        } catch {
            self.error = error
            print("Error fetching weather: \(error)")
        }
    }
    
    private func createWeatherModel(from decodedData: WeatherData) -> WeatherModel {
        // Get current weather from first item in list
        let currentWeather = decodedData.list[0]
        
        // Create forecast array - group by day and get min/max
        var dailyForecasts: [DayForecast] = []
        let groupedForecasts = Dictionary(grouping: decodedData.list) { item -> String in
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
        
        // Sort days and take first 5
        let sortedDays = groupedForecasts.keys.sorted().prefix(5)
        
        for day in sortedDays {
            if let forecasts = groupedForecasts[day] {
                let maxTemp = forecasts.map { $0.main.temp_max }.max() ?? 0
                let minTemp = forecasts.map { $0.main.temp_min }.min() ?? 0
                let avgPop = forecasts.map { $0.pop }.reduce(0, +) / Double(forecasts.count)
                
                let dayForecast = DayForecast(
                    date: Date(timeIntervalSince1970: TimeInterval(forecasts[0].dt)),
                    maxTemp: maxTemp,
                    minTemp: minTemp,
                    conditionId: forecasts[0].weather[0].id,
                    precipitationChance: avgPop
                )
                dailyForecasts.append(dayForecast)
            }
        }
        
        return WeatherModel(
            conditionId: currentWeather.weather[0].id,
            cityName: decodedData.city.name,
            temperature: currentWeather.main.temp,
            windSpeed: currentWeather.wind.speed,
            description: currentWeather.weather[0].description,
            pressure: currentWeather.main.pressure,
            humidity: currentWeather.main.humidity,
            sunrise: Date(timeIntervalSince1970: TimeInterval(decodedData.city.sunrise)),
            sunset: Date(timeIntervalSince1970: TimeInterval(decodedData.city.sunset)),
            precipitationChance: currentWeather.pop,
            forecast: dailyForecasts
        )
    }
}

