//
//  CollectionMenuCollectionViewController.swift
//  TestWeather
//
//  Created by mac on 12/19/18.
//  Copyright © 2018 SINED. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"

class MenuCVC: UICollectionViewController, MenuCVCDelegate {
    
    @IBAction func locationCleanButton(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "selectedCities")
        selectedCities = []
        collectionView.reloadData()
    }
    
    var selectedCities = [ParseCity]()
    
    let weatherRequest = WeatherRequest.init()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUserDefaults()
        print(selectedCities.count)
        requestWeatherForDefauldCities(selectedCities: selectedCities)
        //collectionView.reloadData()
        designNavController()
        self.collectionView.backgroundColor = darkGrey
    }

    func designNavController() {
        self.navigationController?.navigationBar.backgroundColor = darkGrey
        self.navigationController?.navigationBar.barTintColor = darkGrey
        self.navigationController?.navigationBar.tintColor = darkGrey
        self.navigationController?.navigationBar.accessibilityIgnoresInvertColors = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.backgroundColor : UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.backgroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    func dataChanged(city: ParseCity) {
        var cityToAppend = city
        weatherRequest.weatherRequest(cityToRequest: city) { (cityWeather) -> Void in
            self.collectionView.reloadData()
            cityToAppend.cityWeather = cityWeather
            self.selectedCities.append(cityToAppend)
            self.collectionView.reloadData()
            self.defaults.set(try? PropertyListEncoder().encode(self.selectedCities), forKey: "selectedCities")
        }
    }
    
    func requestWeatherForDefauldCities(selectedCities: [ParseCity]?) {
        if selectedCities == nil { return }
        for i in 0..<selectedCities!.count {
            weatherRequest.weatherRequest(cityToRequest: selectedCities![i]) { (cityWeather) in
                self.selectedCities[i].cityWeather = cityWeather
                self.collectionView.reloadData()
            }
        }
    }
    
    func checkForUserDefaults() {
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
        default:
            break
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
        //print(decideOptionalTemp(oneCity: selectedCities[indexPath.row]))
        cell.temperatureLabel.text = temperature
        return cell
    }
    
    func decideOptionalTemp(oneCity: ParseCity) -> String {
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
    
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
