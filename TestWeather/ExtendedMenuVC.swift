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
    var sortListOfWeather = [[ListOfWeather]]()
    
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
    
    @IBOutlet weak var barWeatherButton0: WeatherBarButton!
    @IBOutlet weak var barWeatherButton1: WeatherBarButton!
    @IBOutlet weak var barWeatherButton2: WeatherBarButton!
    @IBOutlet weak var barWeatherButton3: WeatherBarButton!
    @IBOutlet weak var barWeatherButton4: WeatherBarButton!
    
    @IBOutlet var barWeatherButtonCollection: [WeatherBarButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortListOfWeather = sortWeatherByDays(city: city!)
        designNavController()
        setLabelsStyle()
        view.backgroundColor = darkGrey
        self.title = city?.name
        setLabelsText(weather: sortListOfWeather[0][0])
        setThreeImages()
        setUpButtons()
        setButtonsColor(number: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        city = nil
    }
    
    func setUpButtons() {
        for i in 0..<barWeatherButtonCollection.count {
            buttonTitles(button: barWeatherButtonCollection[i], index: i)
        }
    }
    
    func buttonTitles(button: WeatherBarButton, index: Int) {
        button.setup()
        button.backgroundColor = lightGrey
        button.temperatureLabel.text = convertTemp(temp: sortListOfWeather[index][0].mainOfWeather.temp)
        button.weekdayLabel.text = sortListOfWeather[index][0].weekday
        button.weatherImageView?.image = caseForWeather(weather: sortListOfWeather[index][0])
    }
   
    func sortWeatherByDays(city: ParseCity) -> [[ListOfWeather]] {
        var sortedList = [[ListOfWeather]]()
        let listOfWeather = city.cityWeather!.listOfWeather
        for i in 0..<listOfWeather.count {
            var oneDay = [ListOfWeather]()
            for k in 0..<listOfWeather.count {
                if listOfWeather[k].weekday == listOfWeather[i].weekday {
                    oneDay.append(listOfWeather[k])
                }
            }
            sortedList.append(oneDay)
        }
        return sortedList.uniqued()
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
    
    func caseForWeather(weather: ListOfWeather) -> UIImage {
        let variable = weather.weatherDescription.main
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
    
    func convertTemp(temp: String) -> String {
        let kelvinKoef: Double = 273
        guard let temp = Double(temp) else { return String() }
        let tempC = temp - kelvinKoef
        let string = String.init(format: "%.f", tempC) + "°C"
        return string
    }
    
    func setThreeImages() {
        let humidityImage = UIImage.init(named: "Humidity")
        humidityImageView.image = humidityImage
        let rainImage = UIImage.init(named: "Rain_chance")
        chanceImageView.image = rainImage
        let windImage = UIImage.init(named: "Wind")
        windImageView.image = windImage
    }
    
    func setLabelsStyle() {
        windNameLabel.text = "Wind"
        windNameLabel.textColor = white
        chanceNameLabel.text = "Chance"
        chanceNameLabel.textColor = white
        humidityNameLabel.text = "Humidity"
        humidityNameLabel.textColor = white
        humidityLabel.textColor = white
        windSpeedLabel.textColor = white
        chanceLabel.textColor = white
        currentTempLabel.textColor = white
    }
    
    func setLabelsText(weather: ListOfWeather) {
        currentTempLabel.text = konvertCelvins(celvins: weather.mainOfWeather.temp)
        humidityLabel.text = weather.mainOfWeather.humidity + "%"
        windSpeedLabel.text = weather.wind.speed + "m/s"
        let rain = weather.rain.chance
        print(rain)
        if rain == "nil" {
            chanceLabel.text = "0" + "%"
        } else {
            chanceLabel.text = String.init(format: "%.f1", rain) + "%"
        }
        bigWeatherImageView.image = caseForWeather(weather: weather)
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
    
    func setButtonsColor(number: Int) {
        for i in 0..<barWeatherButtonCollection.count {
            barWeatherButtonCollection[i].backgroundColor = lightGrey
        }
        barWeatherButtonCollection[number].backgroundColor = orange
    }
    
    @IBAction func barWeatherButtonAction0(_ sender: UIButton) {
        setLabelsText(weather: sortListOfWeather[0][0])
        setButtonsColor(number: 0)
    }
    
    @IBAction func barWeatherButtonAction1(_ sender: Any) {
        setLabelsText(weather: sortListOfWeather[1][0])
        setButtonsColor(number: 1)
    }
    
    @IBAction func barWeatherButtonAction2(_ sender: Any) {
        setLabelsText(weather: sortListOfWeather[2][0])
        setButtonsColor(number: 2)
    }
    
    @IBAction func barWeatherButtonAction3(_ sender: Any) {
        setLabelsText(weather: sortListOfWeather[3][0])
        setButtonsColor(number: 3)
    }
    
    @IBAction func barWeatherButtonAction4(_ sender: Any) {
        setLabelsText(weather: sortListOfWeather[4][0])
        setButtonsColor(number: 4)
    }
    
    @IBAction func deleteCityButton(_ sender: Any) {
        
    }
}

public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}


