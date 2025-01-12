//
//  WeatherData.swift
//  Clima
//
//  Created by Gero Walther on 13/10/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let list: [WeatherList]
    let city: City
}

struct City: Codable {
    let name: String
    let sunrise: Int
    let sunset: Int
}

struct WeatherList: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let pop: Double
    let dt_txt: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
}

struct Weather: Codable {
    let id: Int
    let description: String
}

struct Clouds: Codable {
    let all: Int
}

struct Wind: Codable {
    let speed: Double
}
