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
    private let lastSearchKey = "LastWeatherSearch"
    private let defaults = UserDefaults.standard
    
    private enum SearchType: String, Codable {
        case city
        case coordinates
    }
    
    private struct LastSearch: Codable {
        let type: SearchType
        let cityName: String?
        let latitude: Double?
        let longitude: Double?
    }
    
    private func saveLastSearch(type: SearchType, cityName: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        let search = LastSearch(type: type, cityName: cityName, latitude: latitude, longitude: longitude)
        if let encoded = try? JSONEncoder().encode(search) {
            defaults.set(encoded, forKey: lastSearchKey)
        }
    }
    
    func loadLastSearch() {
        guard let data = defaults.data(forKey: lastSearchKey),
              let lastSearch = try? JSONDecoder().decode(LastSearch.self, from: data) else {
            return
        }
        
        switch lastSearch.type {
        case .city:
            if let cityName = lastSearch.cityName {
                fetchWeather(cityName: cityName)
            }
        case .coordinates:
            if let latitude = lastSearch.latitude,
               let longitude = lastSearch.longitude {
                fetchWeather(latitude: latitude, longitude: longitude)
            }
        }
    }
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        saveLastSearch(type: .city, cityName: cityName)
        Task {
            await performRequest(with: urlString)
        }
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        saveLastSearch(type: .coordinates, latitude: latitude, longitude: longitude)
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

