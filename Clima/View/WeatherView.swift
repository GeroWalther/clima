import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherManager = WeatherManager()
    @StateObject private var locationService = LocationService.shared
    @State private var searchText = ""
    @State private var isLoading = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        Group {
            if #available(iOS 15.0, *) {
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.039, green: 0.016, blue: 0.235),
                            Color(red: 0.039, green: 0.016, blue: 0.335)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ).ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Search Bar
                            HStack {
                                TextField("Search city...", text: $searchText)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, 8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .focused($isSearchFocused)
                                    .onSubmit {
                                        performSearch()
                                    }
                                
                                Button {
                                    isSearchFocused = false  // Dismiss keyboard
                                    performSearch()
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: locationService.requestLocation) {
                                    Image(systemName: "location.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)
                            
                            Group {
                                if isLoading && weatherManager.weather == nil {
                                    VStack(spacing: 20) {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                            .tint(.white)
                                        Text("Loading weather data...")
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(.top, 100)
                                } else if let weather = weatherManager.weather {
                                    WeatherContentView(weather: weather)
                                        .onAppear {
                                            isLoading = false
                                        }
                                }
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                .task {
                    await locationService.requestLocationPermission()
                    if locationService.location == nil {
                        weatherManager.loadLastSearch()
                    }
                }
                .onChange(of: locationService.location) { _ in
                    if let location = locationService.location {
                        isLoading = true
                        weatherManager.fetchWeather(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    }
                }
            } else {
                ZStack {
                    Color(red: 0.039, green: 0.016, blue: 0.235)
                        .ignoresSafeArea()
                    Text("Please update to iOS 15.0 or later")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        weatherManager.fetchWeather(cityName: searchText)
    }
}

struct WeatherContentView: View {
    let weather: WeatherModel
    
    var body: some View {
        VStack(spacing: 30) {
            // Current Weather Section
            VStack(spacing: 15) {
                Text(weather.cityName)
                    .font(.system(size: 35, weight: .medium))
                    .foregroundColor(.white)
                
                Text(weather.tempString)
                    .font(.system(size: 85, weight: .bold))
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: weather.conditionName)
                        .font(.system(size: 45))
                    Text(weather.description.capitalized)
                        .font(.title2)
                }
                .foregroundColor(.white)
            }
            .padding(.bottom, 20)
            
            // Weather Details Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                WeatherDetailCard(icon: "wind", title: "Wind", value: weather.windSpeedString)
                WeatherDetailCard(icon: "gauge.medium", title: "Pressure", value: "\(weather.pressure) hPa")
                WeatherDetailCard(icon: "humidity", title: "Humidity", value: "\(weather.humidity)%")
                WeatherDetailCard(icon: "cloud.rain", title: "Rain", value: "\(Int(weather.precipitationChance * 100))%")
                WeatherDetailCard(icon: "sunrise.fill", title: "Sunrise", value: weather.sunriseString)
                WeatherDetailCard(icon: "sunset.fill", title: "Sunset", value: weather.sunsetString)
            }
            .padding(.horizontal)
            
            // Forecast Section
            VStack(alignment: .leading, spacing: 10) {
                Text("5-Day Forecast")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(weather.forecast, id: \.date) { forecast in
                            DayForecastView(forecast: forecast)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct WeatherDetailCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.title3)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .foregroundColor(.white)
    }
}

struct DayForecastView: View {
    let forecast: DayForecast
    
    var body: some View {
        VStack(spacing: 12) {
            Text(forecast.dayString)
                .font(.title3)
                .bold()
            
            Image(systemName: WeatherModel.getConditionName(forecast.conditionId))
                .font(.system(size: 35))
            
            VStack(spacing: 5) {
                Text(forecast.maxTempString)
                    .font(.title3)
                    .bold()
                
                Text(forecast.minTempString)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Text(forecast.precipitationString)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .frame(width: 120)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .foregroundColor(.white)
    }
}

#Preview {
    WeatherView()
} 
