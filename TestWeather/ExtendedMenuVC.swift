//
//  ExtendedMenuVC.swift
//  TestWeather
//
//  Created by mac on 12/28/18.
//  Copyright © 2018 SINED. All rights reserved.
//

import UIKit

class ExtendedMenuVC: UIViewController {
    
    var city: ParseCity?

    @IBOutlet weak var bigWeatherImageView: UIImageView!
    @IBOutlet weak var windImageView: UIImageView!
    @IBOutlet weak var chanceImageView: UIImageView!
    @IBOutlet weak var humidityImageView: UIImageView!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windNameLabel: UILabel!
    @IBOutlet weak var chanceLabel: UILabel!
    @IBOutlet weak var chanceNameLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var humidityNameLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    
    @IBOutlet weak var weatherBarIcon: WeatherBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designNavController()
        view.backgroundColor = darkGrey
        self.title = city?.name
        setBigImage(cityWithImage: city)
        setLabels(cityWithTemp: city)
        setThreeImages()
        setUpBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        city = nil
    }
    
    func setUpBar() {
        weatherBarIcon.setup()
        weatherBarIcon.backgroundColor = orange
        weatherBarIcon.temperatureText = "100"
    }
    
    func setBigImage(cityWithImage: ParseCity?) {
        guard let cityWithImage = cityWithImage else { return }
        let image = caseForWeather(city: cityWithImage)
        bigWeatherImageView.image = image
    }
    
    func designNavController() {
        self.navigationController?.navigationBar.backgroundColor = darkGrey
        self.navigationController?.navigationBar.barTintColor = darkGrey
        self.navigationController?.navigationBar.tintColor = white
        self.navigationController?.navigationBar.accessibilityIgnoresInvertColors = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.backgroundColor : UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.backgroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.title = city?.name
    }
    
    func caseForWeather(city: ParseCity) -> UIImage {
        guard let variable = city.cityWeather?.listOfWeather[0].weatherDescription.main else { return UIImage() }
        switch variable {
        case "Thunderstorm":
            return UIImage.init(named: "Weather2_Big")!
        case "Drizzle":
            return UIImage.init(named: "Weather5_Big")!
        case "Rain":
            return UIImage.init(named: "Weather5_Big")!
        case "Snow":
            return UIImage.init(named: "Weather1_Big")!
        case "Clear":
            return UIImage.init(named: "Weather3_Big")!
        case "Clouds":
            return UIImage.init(named: "Weather4_Big")!
        default:
            print("none of cases accepted")
            return UIImage()
        }
    }
    
    func setThreeImages() {
        let humidityImage = UIImage.init(named: "Humidity")
        humidityImageView.image = humidityImage
        let rainImage = UIImage.init(named: "Rain_chance")
        chanceImageView.image = rainImage
        let windImage = UIImage.init(named: "Wind")
        windImageView.image = windImage
    }
    
    func setLabels(cityWithTemp: ParseCity?) {
        guard let cityNoOpt = cityWithTemp else { return }
        currentTempLabel.textColor = white
        guard let currentTemp = cityWithTemp?.cityWeather?.listOfWeather[0].mainOfWeather.temp else { return }
        currentTempLabel.text = konvertCelvins(celvins: currentTemp)
        windNameLabel.text = "Wind"
        windNameLabel.textColor = white
        chanceNameLabel.text = "Chance"
        chanceNameLabel.textColor = white
        humidityNameLabel.text = "Humidity"
        humidityNameLabel.textColor = white
        guard let humidity = cityNoOpt.cityWeather?.listOfWeather[0].mainOfWeather.humidity else { return }
        humidityLabel.text = humidity + "%"
        humidityLabel.textColor = white
        guard let windSpeed = cityNoOpt.cityWeather?.listOfWeather[0].wind.speed else { return }
        windSpeedLabel.text = windSpeed + "m/s"
        windSpeedLabel.textColor = white
        chanceLabel.textColor = white
        guard let rain = cityNoOpt.cityWeather?.listOfWeather[0].rain.chance else { return }
        if rain == "" {
            chanceLabel.text = "0" + "%"
        } else {
            chanceLabel.text = String.init(format: "%.f1", rain) + "%"
        }
    }
    
    func konvertCelvins(celvins: String) -> String {
        let kelvinKoef: Double = 273
        guard let celvini = Double(celvins) else { return String() }
        let celsii = celvini - kelvinKoef
        let string = String.init(format: "%.f", celsii) + "°"
        return string
    }
    
    private func decideOptional(optionalValue: Any?) -> String {
        guard let value = optionalValue else { return String() }
        let string = String(describing: value)
        return string
    }
    
}
