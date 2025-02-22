import Foundation
import CoreLocation
import Combine

class WeatherManager: ObservableObject {
    @Published var weather: WeatherModel?
    
    private let weatherUrl = "https://api.openweathermap.org/data/2.5/forecast?appid=32e8ebacafb05c5146276b7ff2ed55bb&units=metric"
    private var cancellables = Set<AnyCancellable>()
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    private func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] decodedData in
                self?.weather = self?.createWeatherModel(from: decodedData)
            }
            .store(in: &cancellables)
    }
    
    private func createWeatherModel(from decodedData: WeatherData) -> WeatherModel? {
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
            forecast: dailyForecasts
        )
    }
}