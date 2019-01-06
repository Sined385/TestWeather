//
//  CollectionMenuCollectionViewController.swift
//  TestWeather
//
//  Created by mac on 12/19/18.
//  Copyright © 2018 SINED. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

private let reuseIdentifier = "cell"

class MenuCVC: UICollectionViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var latitude: String?
    var longtitude: String?
    
    let extendedVC = ExtendedMenuVC()

    @IBAction func locationCleanButton(_ sender: Any) {
        //let defaults = UserDefaults.standard
        //defaults.set(nil, forKey: "selectedCities")
        //selectedCities = []
        weatherRequest.requestByCoordinates(lon: longtitude!, lat: latitude!)
        collectionView.reloadData()
    }
    
    var selectedCities = [ParseCity]()
    var currentIndex: IndexPath?
    let weatherRequest = WeatherRequest.init()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUserDefaults()
        requestWeatherForDefauldCities(selectedCities: selectedCities)
        collectionView.reloadData()
        designNavController()
        self.collectionView.backgroundColor = darkGrey
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    self.latitude = String.init(format: "%.f", locationManager.location!.coordinate.latitude)
                    self.longtitude = String.init(format: "%.f", locationManager.location!.coordinate.longitude)
                }
            }
        }
    }

    private func designNavController() {
        self.navigationController?.navigationBar.backgroundColor = darkGrey
        self.navigationController?.navigationBar.barTintColor = darkGrey
        self.navigationController?.navigationBar.tintColor = darkGrey
        self.navigationController?.navigationBar.accessibilityIgnoresInvertColors = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.backgroundColor : UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.backgroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    private func requestWeatherForDefauldCities(selectedCities: [ParseCity]?) {
        if selectedCities == nil { return }
        for i in 0..<selectedCities!.count {
            weatherRequest.weatherRequest(cityToRequest: selectedCities![i]) { (cityWeather) in
                self.selectedCities[i].cityWeather = cityWeather
                self.collectionView.reloadData()
            }
        }
    }
    
    private func checkForUserDefaults() {
        guard let citiesData = defaults.object(forKey: "selectedCities") as? Data else {
            selectedCities = [ParseCity]()
            return
        }
        guard let cities = try? PropertyListDecoder().decode([ParseCity].self, from: citiesData ) else { return }
        selectedCities = cities
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = segue.identifier else { return }
        switch segueID {
        case "tableSegue":
            let tableVC = segue.destination as! MainVC
            tableVC.delegateToMenu = self
            break
        case "extendedMenuSegue":
            let extendedMenu = segue.destination as! ExtendedMenuVC
            guard let index = currentIndex else { return }
            print("segueIndex \(index)")
            extendedMenu.city = selectedCities[index.row]
        default:
            break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath
        collectionView.reloadData()
        performSegue(withIdentifier: "extendedMenuSegue", sender: nil)
    }
    
   
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedCities.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MenuCollectionCell
        cell.backgroundColor = lightGrey
        cell.cityLabel.text = selectedCities[indexPath.row].name
        cell.cityLabel.textColor = white
        cell.temperatureLabel.textColor = white
        guard let temperatureMin = selectedCities[indexPath.row].cityWeather?.listOfWeather[0].mainOfWeather.tempMin else { return UICollectionViewCell() }
         guard let temperatureMax = selectedCities[indexPath.row].cityWeather?.listOfWeather[0].mainOfWeather.tempMax else { return UICollectionViewCell() }
        let temperature = makeMinAndMaxTemp(minTemp: temperatureMin, maxTemp: temperatureMax)
        cell.temperatureLabel.text = temperature
        cell.weatherIconView.image = caseForWeather(city: selectedCities[indexPath.row])
        let longPress = setUpLongPress(indexPath: indexPath.row)
        cell.addGestureRecognizer(longPress)
        return cell
    }
    
    private func decideOptionalTemp(oneCity: ParseCity) -> String {
        guard let weather = oneCity.cityWeather?.listOfWeather[0].mainOfWeather.temp else { return String() }
        return weather
    }
    
    func makeMinAndMaxTemp(minTemp: String, maxTemp: String) -> String {
        let kelvinKoef: Double = 273
        guard let minimum = Double(minTemp) else { return String() }
        guard let maximum = Double(maxTemp) else { return String() }
        let min = minimum - kelvinKoef
        let max = maximum - kelvinKoef
        let string = String.init(format: "%.f", max) + "/" + String.init(format: "%.f", min) + " °C"
        return string
    }
    
    private func caseForWeather(city: ParseCity) -> UIImage {
        guard let variable = city.cityWeather?.listOfWeather[0].weatherDescription.main else { return UIImage() }
        switch variable {
        case "Thunderstorm":
            return UIImage.init(named: "Weather2")!
        case "Drizzle":
            return UIImage.init(named: "Weather5")!
        case "Rain":
            return UIImage.init(named: "Weather5")!
        case "Snow":
            return UIImage.init(named: "Weather1")!
        case "Clear":
            return UIImage.init(named: "Weather3")!
        case "Clouds":
            return UIImage.init(named: "Weather4")!
        default:
            print("none of cases accepted")
            return UIImage()
        }
    }
    
    private func decideOptional(optionalValue: Any?) -> String {
        guard let value = optionalValue else { return String() }
        let string = String(describing: value)
        return string
    }
    
    @objc func addLongPressGesture(gesture: CustomLongPress) {
        if gesture.state == .began {
            print("long tap")
            guard let gestureIndex = gesture.cellIndex else { return }
            collectionView.cellForItem(at: IndexPath.init(row: gestureIndex, section: 0))?.backgroundColor = UIColor.red
        }
        if gesture.state == .ended {
            createDeleteAlert(index: gesture.cellIndex!)
        }
    }
    
    func setUpLongPress(indexPath: Int) -> CustomLongPress {
        let longPressGesture = CustomLongPress.init(target: self, action: #selector(addLongPressGesture(gesture:)))
        longPressGesture.setIndex(index: indexPath)
        longPressGesture.minimumPressDuration = 1.0
        return longPressGesture
    }
    
    func createDeleteAlert(index: Int) {
        let alert = UIAlertController.init(title: "Delete \(selectedCities[index].name)?", message: nil, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default) { (UIAlertAction) in
            self.selectedCities.remove(at: index)
            self.defaults.set(try? PropertyListEncoder().encode(self.selectedCities), forKey: "selectedCities")
            self.collectionView.reloadData()
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel) { (UIAlertAction) in
            self.collectionView.cellForItem(at: IndexPath.init(row: index, section: 0))?.backgroundColor = lightGrey
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}

extension MenuCVC: MenuCVCDelegate {
    
    internal func dataChanged(city: ParseCity) {
        var cityToAppend = city
        weatherRequest.weatherRequest(cityToRequest: city) { (cityWeather) -> Void in
            cityToAppend.cityWeather = cityWeather
            self.selectedCities.append(cityToAppend)
            self.collectionView.reloadData()
            self.defaults.set(try? PropertyListEncoder().encode(self.selectedCities), forKey: "selectedCities")
        }
    }
    
}
