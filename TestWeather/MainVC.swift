//
//  MainVC.swift
//  TestWeather
//
//  Created by mac on 11/14/18.
//  Copyright © 2018 SINED. All rights reserved.
//

import UIKit
import TableManager
import SwiftyJSON
import Alamofire


class MainVC: UITableViewController {
    
    let cellID = "CityCell"
    let darkGrey = UIColor.init(hexString: "#191D20")
    let lightGrey = UIColor.init(hexString: "1F2427")
    let orange = UIColor.init(hexString: "#F58223")
    let white = UIColor.init(hexString: "#FFFFFF")
    let lettersArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
                        "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var citiesList: [String : ParseCity] = [:]
    var filteredCities = [(key: String, value: [ParseCity])]()
    var filteredCitiesForTable = [ParseCity]()
    var sortedCitiesDict = [(key: String, value: [ParseCity])]()
    var cities = [ParseCity.init(name: "Loh", id: nil, country: nil, coord: nil), ParseCity.init(name: "Pidor", id: nil, country: nil, coord: nil), ParseCity.init(name: "Aloha", id: nil, country: nil, coord: nil), ParseCity.init(name: "Allah", id: nil, country: nil, coord: nil), ParseCity.init(name: "Shit", id: nil, country: nil, coord: nil), ParseCity.init(name: "Luftwaffe", id: nil, country: nil, coord: nil), ParseCity.init(name: "Piter", id: nil, country: nil, coord: nil), ParseCity.init(name: "Swift", id: nil, country: nil, coord: nil)]
    
    @IBOutlet weak var citiesTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeTable()
        createSearchController()
        designNavController()
        searchControllerDesign()
        tableViewDesign()
        sortedCitiesDict = sortDictionaryForCities()
    }
    
    func makeTable() {
        for i in 0..<citiesList.count {
            citiesTableView.addRow().setConfiguration { (_, cell, _) in
                let namesArray = Array(self.citiesList.keys)
                print(self.citiesList.count)
                print("names array got")
                cell.textLabel?.text = namesArray[i]
            }
        }
    }
    
    func tableViewDesign() {
        self.tableView.backgroundColor = darkGrey
        tableView.separatorColor = lightGrey
    }
    
    func sortCities(cities: [ParseCity]) -> [ParseCity] {
        let citiesSorted = cities.sorted(by: {$0.name < $1.name})
        return citiesSorted
    }
    
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
        print(citiesDictForTable)
        return citiesDictForTable
    }
    
    func sortDictionaryForCities() -> [(key: String, value: [ParseCity])] {
        let sortedDict = makeCitiesDict().sorted(by: { $0.0 < $1.0 })
        return sortedDict
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
        cell.detailTextLabel?.textColor = white
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        print("filtered \(filteredCitiesForTable)")
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
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

struct ParseCity: Decodable {
    var name: String
    var id: String?
    var country: String?
    var coord: ParseCoord?
}

struct ParseCoord: Decodable {
    var lon: String?
    var lat: String?
}




