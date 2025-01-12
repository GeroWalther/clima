struct ExtendedWeatherData: Codable {
    let current: Current
    let daily: [Daily]
    let timezone: String
}

struct Current: Codable {
    let temp: Double
    let pressure: Int
    let humidity: Int
    let uvi: Double
    let clouds: Int
    let wind_speed: Double
    let weather: [Weather]
    let sunrise: Int
    let sunset: Int
}

struct Daily: Codable {
    let dt: Int
    let temp: DailyTemp
    let weather: [Weather]
    let pop: Double // Probability of precipitation
}

struct DailyTemp: Codable {
    let day: Double
    let min: Double
    let max: Double
} 