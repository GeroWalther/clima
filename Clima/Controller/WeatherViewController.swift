//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
class WeatherViewController: UIViewController {

    
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var textInput: UITextField!
    
    var weatherManager = WeatherManager()
    let coreLoco = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreLoco.delegate = self
        coreLoco.requestWhenInUseAuthorization()
        coreLoco.requestLocation()
// self refers to the current view controller
// with delegate the textField can communicate to the viewController whenever something happens on it. Needed as setup for textFieldShouldReturn
        textInput.delegate = self
        weatherManager.delegate = self
      
    }
    @IBAction func GPSLocationBtn(_ sender: UIButton) {
        coreLoco.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            coreLoco.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lng)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
}

// MARK: - UITextFieldDelegate
    // extension for the UITextFieldDelegate and all of its funcs
extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPress(_ sender: UIButton) {
        textInput.endEditing(true)
        print(textInput.text!)
    }
    
    // this is like a IBAction to the return button of the TextInput. We need to return true or false at the end to allow the textField to proceed with this action. func with Should ask for permissions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textInput.endEditing(true)
        print(textInput.text!)
        return true
    }
    
    // should we allow the user to stop editing when user tries to deselect the textfield. useful for validation
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }else{
            textField.placeholder = "Type something"
            return false
        }
    }
    
    //this runs once the user stopped editing since this class is the deligate of the textInput. works for all textInputs on the screen.
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = textInput.text {
            weatherManager.fetchWeather(cityName: city)
        }
        textInput.text = ""
    }
    
    
}
// MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){
        DispatchQueue.main.async{
            self.temperatureLabel.text = weather.tempString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
            self.descriptionLabel.text = weather.description
            self.windSpeedLabel.text = weather.windSpeedString
        }
      
    }
    func didFailWithError(error: Error){
        print(error)
    }
}
