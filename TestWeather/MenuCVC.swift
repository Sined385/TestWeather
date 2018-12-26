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
        collectionView.reloadData()
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
        selectedCities.append(city)
        print(selectedCities)
        self.collectionView.reloadData()
        defaults.set(try? PropertyListEncoder().encode(selectedCities), forKey: "selectedCities")
        weatherRequest.weatherRequest(city: city)
    }
    
    func checkForUserDefaults() {
        print("checkForUs")
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
        return cell
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
