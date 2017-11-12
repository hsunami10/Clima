//
//  ChangeCityViewController.swift
//  Clima
//

import UIKit

// Create a protocol
// Similar to a "contract" (interface in Java) - if you want to be a delegate, you have to implement this delegate method
protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

// Reusable component
class ChangeCityViewController: UIViewController {
    
    // Create a delegate
    var delegate: ChangeCityDelegate?
    
    // This is the pre-linked IBOutlets to the text field:
    @IBOutlet weak var changeCityTextField: UITextField!

    
    //T his is the IBAction that gets called when the user taps on the "Get Weather" button:
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        // Get the city name the user entered in the text field
        let cityName = changeCityTextField.text!
        
        // If we have a delegate set, call the method userEnteredANewCityName from WeatherViewController
        // Optional chaining
        delegate?.userEnteredANewCityName(city: cityName)
        
        // Dismiss the Change City View Controller to go back to the WeatherViewController
        self.dismiss(animated: true, completion: nil)
    }
    
    

    // This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
