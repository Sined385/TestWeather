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


class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellID = "CityCell"
    
    var citiesList: [String : ParseCity] = [:]
    
    @IBOutlet weak var citiesTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search city"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        assignToCities()
        for i in 0..<citiesList.count {
            citiesTableView.addRow().setConfiguration { (_, cell, _) in
                
            }
        }
    }
    
    func assignToCities() {
        
        let path = Bundle.main.path(forResource: "city.list", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        request(url).responseJSON { (response) in
            switch(response.result) {
            case .success(let data):
                print("got data")
                let json = data as! [[String : AnyObject]]
                for i in 0..<json.count {
                    guard let key = json[i]["name"] else { return }
                    guard let id = json[i]["id"] else { return }
                    guard let country = json[i]["country"] else  { return }
                    guard let lon = json[i]["coord"]?["lon"] else { return }
                    guard let lat = json[i]["coord"]?["lat"] else { return }
                    let coord = ParseCoord.init(lon: String.init(describing: lon), lat: String.init(describing: lat))
                    let cityProperty = ParseCity.init(id: String.init(describing: id), country: (country as! String), coord: coord)
                    self.citiesList.updateValue(cityProperty, forKey: key as! String)
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
}

extension MainVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = citiesTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        //cell.detailTextLabel?.text = citiesList[indexPath.row]
        return cell
    }
    
}

extension MainVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
     
    }
}

struct ParseCity: Decodable {
    var id: String?
    var country: String?
    var coord: ParseCoord?
}

struct ParseCoord: Decodable {
    var lon: String?
    var lat: String?
}
