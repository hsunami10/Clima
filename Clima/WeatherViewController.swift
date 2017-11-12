//
//  ViewController.swift
//  Clima
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

/*
 A protocol is very similar to an interface in Java. It's like a template / contract.
 A class can inherit from a protocol, and has to implement all the necessary delegate methods.
 Declaring yourself as a delegate means that you will listen and receive all events that will happen.
 The components that have the delegate instance variable are reusable, because they can take any view controller (x.delegate = self)
 Any time you want to "send back", you need a delegate and protocol
 */

// Make this class listen to delegates of CL
// Class has to "conform" to the ChangeCityDelegate protocol
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    // Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"

    // TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    var type: String = "Fahrenheit"
    var temp: Double = 0.0
    
    // Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up location manager
        locationManager.delegate = self // Set this instance as delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // For asking for permissions to use location, add this to in Info.plist:
        // Privacy - Location Usage Description
        // Privacy - When in Use Description
        locationManager.requestWhenInUseAuthorization()
        
        // Asynchronous (runs in background)
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func changeType(_ sender: UIButton) {
        if sender.titleLabel?.text == "Celsius" {
            sender.setTitle("Fahrenheit", for: .normal)
            temp = 1.8 * temp + 32
            type = "Fahrenheit"
        } else {
            sender.setTitle("Celsius", for: .normal)
            temp = (temp - 32) / 1.8
            type = "Celsius"
        }
        weatherDataModel.temperature = Int(temp)
        updateUIWithWeatherData()
    }
    
    
    // MARK: - Networking
    // HTTP get request the weather
    func getWeatherData(url: String, parameters: [String : String]) {
        // async HTTP get request
        // Need self keyword in a closure
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            // If the request is successful
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!) // Cast to String JSON
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Error: \(response.result.error!)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    // MARK: - JSON Parsing
    // Update weather data after getting JSON
    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double {
            temp = tempResult - 273.15 // Default Celsius
            // Set for celsius and fahrenheit
            if type == "Fahrenheit" {
                temp = 1.8 * temp + 32 // Convert C to F
            }
            weatherDataModel.temperature = Int(temp)
            weatherDataModel.city = json["name"].stringValue // Set city
            weatherDataModel.condition = json["weather"][0]["id"].intValue // Set weather condition
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition) // Icon
            updateUIWithWeatherData() // After properties are updated, then update UI
        } else {
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    // MARK: - UI Updates
    // Update UI after getting updating data
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    // MARK: - Location Manager Delegate Methods
    // Run when location is updated (startUpdatingLocation)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get last location in array (most precise)
        let location = locations[locations.count-1]
        
        // Check if valid - accuracy = radius of user's possible locations
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params: [String : String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    // Run if location manager can't retrieve a location value
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    // MARK: - ChangeCityDelegate methods
    func userEnteredANewCityName(city: String) {
        let params: [String : String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    // Run before switching view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            // Force cast segue destination to type ChangeCityViewController
            let destinationVC = segue.destination as! ChangeCityViewController
            // Change ChangeCityViewController delegate to be this class instance
            destinationVC.delegate = self
        }
    }
    
}


