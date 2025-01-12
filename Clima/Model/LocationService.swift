import CoreLocation

@MainActor
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    @Published var location: CLLocation?
    private let manager = CLLocationManager()
    
    override private init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocationPermission() async {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
