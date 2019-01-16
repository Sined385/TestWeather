//
//  MainVC.swift
//  TestWeather
//
//  Created by mac on 11/14/18.
//  Copyright © 2018 SINED. All rights reserved.
//

let darkGrey = UIColor.init(hexString: "#191D20")
let lightGrey = UIColor.init(hexString: "1F2427")
let orange = UIColor.init(hexString: "#F58223")
let white = UIColor.init(hexString: "#FFFFFF")

import UIKit
import SwiftyJSON
import Alamofire

let kBgQ = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
let mainQ = DispatchQueue.main

class MainVC: UITableViewController {
    
    let cellID = "CityCell"
    let lettersArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
                        "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var citiesList: [String : ParseCity] = [:]
    var filteredCities = [(key: String, value: [ParseCity])]()
    var filteredCitiesForTable = [ParseCity]()
    var sortedCitiesDict = [(key: String, value: [ParseCity])]()
    var cities = [ParseCity]()
    var selectedCities: ParseCity?
    
    weak var delegateToMenu: MenuCVCDelegate?
    
    @IBOutlet weak var citiesTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awake from nib")
        print(cities.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        makeCitiesList()
        print(cities.count)
        createSearchController()
        designNavController()
        searchControllerDesign()
        tableViewDesign()
        sortedCitiesDict = sortDictionaryForCities()
    }
    
    //get cities data from json file "city.list.json"
    func makeCitiesList() {
        print("making list")
        kBgQ.async {
            if let path = Bundle.main.path(forResource: "city", ofType: "list.json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                    let jsonObj = try JSON(data: data)
                    self.parseCities(json: jsonObj)
                    mainQ.async(execute: {
                        self.sortedCitiesDict = self.sortDictionaryForCities()
                        self.tableView.reloadData()
                    })
                } catch let error {
                    print("parse error: \(error.localizedDescription)")
                }
            } else {
                print("Invalid filename/path.")
            }
        }
    }
    
    //parse cities data
    func parseCities(json: JSON) {
        for i in 0..<json.count {
            let id = json[i]["id"]
            let name = json[i]["name"]
            let country = json[i]["country"]
            let lon = json[i]["coord"]["lon"]
            let lat = json[i]["coord"]["lat"]
            let coord = ParseCoord.init(lon: String(describing: lon), lat: String(describing: lat))
            let city = ParseCity.init(name: String(describing: name), id: String(describing: id), country: String(describing: country), coord: coord, cityWeather: nil)
            cities.append(city)
        }
    }
    
    //table view colors
    func tableViewDesign() {
        self.tableView.backgroundColor = darkGrey
        self.tableView.separatorColor = lightGrey
    }
    
    //sort cities in alphabetic order
    func sortCities(cities: [ParseCity]) -> [ParseCity] {
        let citiesSorted = cities.sorted(by: {$0.name < $1.name})
        return citiesSorted
    }
    
    //make dictionary of cities by one letter as a key
    func makeCitiesDict() -> [String : [ParseCity]] {
        let sortedCities = sortCities(cities: cities)
        var citiesDictForTable: [String : [ParseCity]] = [:]
        for i in 0..<lettersArray.count {
            var arrayForOneLetter = [ParseCity]()
            for k in 0..<sortedCities.count {
                if sortedCities[k].name.hasPrefix(lettersArray[i]) {
                    arrayForOneLetter.append(sortedCities[k])
                    citiesDictForTable.updateValue(arrayForOneLetter, forKey: lettersArray[i])
                }
            }
        }
        return citiesDictForTable
    }
    
    //sort dictionary in alphabetic order
    func sortDictionaryForCities() -> [(key: String, value: [ParseCity])] {
        let sortedDict = makeCitiesDict().sorted(by: { $0.0 < $1.0 })
        return sortedDict
    }
    
    //alert to add one city to collection view controller
    func createAddAlert(city: ParseCity) {
        let alert = UIAlertController.init(title: "Add \(city.name) ?", message: nil, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default) { (UIAlertAction) in
            self.addCity(city: city)
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //function to send data to collection view controller
    func addCity(city: ParseCity) {
        delegateToMenu?.dataChanged(city: city)
        print(city)
    }
    
}

extension MainVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredCitiesForTable.count
        }
        let rows = sortedCitiesDict[section].value.count
        return rows
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        }
        return sortedCitiesDict.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            return nil
        }
        return sortedCitiesDict[section].key
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = white
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.backgroundColor = darkGrey
        cell.textLabel?.textColor = white
        if isFiltering() {
            let text = filteredCitiesForTable[indexPath.row].name
            cell.textLabel?.text = text
        } else {
            let text = sortedCitiesDict[indexPath.section].value[indexPath.row].name
            cell.textLabel?.text = text
        }
        cell.detailTextLabel?.text = "►"
        cell.detailTextLabel?.textColor = lightGrey
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isFiltering() {
            createAddAlert(city: filteredCitiesForTable[indexPath.row])
        } else {
            createAddAlert(city: sortedCitiesDict[indexPath.section].value[indexPath.row])
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

extension MainVC {
    
    func searchControllerDesign() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search city"
        let cancelButtonAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
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
}

extension MainVC:  UISearchResultsUpdating {
    
    //search controller init
    func createSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        var values = [ParseCity]()
        let sortDict = sortDictionaryForCities()
        for i in 0..<sortDict.count {
            values = values + sortDict[i].value
        }
        filteredCitiesForTable = values.filter({ (city) -> Bool in
            return city.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func convertFilteredCities(_ cities: [(key: String, value: [ParseCity])]) -> [ParseCity] {
        var filtered = [ParseCity]()
        for i in 0..<cities.count {
            let values = cities[i].value
            for k in 0..<values.count {
                filtered.append(values[k])
            }
        }
        return filtered
    }
    
    //check if filtering mode on (true = on)
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}






