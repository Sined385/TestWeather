//
//  LoadingVC.swift
//  TestWeather
//
//  Created by mac on 12/12/18.
//  Copyright © 2018 SINED. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

let kBgQ = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
let mainQ = DispatchQueue.main

class LoadingVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCitiesList()
    }
    
    var citiesList = [ParseCity]()
    
    func makeCitiesList() {
        print("making list")
        kBgQ.async {
            if let path = Bundle.main.path(forResource: "city", ofType: "list.json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                    let jsonObj = try JSON(data: data)
                    self.parseCities(json: jsonObj)
                    mainQ.async(execute: {
                        self.performSegue(withIdentifier: "loginToMain", sender: nil)
                        let vcToPresent = self.storyboard?.instantiateViewController(withIdentifier: "Main") as! MainVC
                        self.present(vcToPresent, animated: true, completion: nil)
                    })
                    
                } catch let error {
                    print("parse error: \(error.localizedDescription)")
                }
            } else {
                print("Invalid filename/path.")
            }
        }
    }
   
    func parseCities(json: JSON) {
        for i in 0..<json.count {
            let id = json[i]["id"]
            let name = json[i]["name"]
            let country = json[i]["country"]
            let lon = json[i]["coord"]["lon"]
            let lat = json[i]["coord"]["lat"]
            let coord = ParseCoord.init(lon: String(describing: lon), lat: String(describing: lat))
            let city = ParseCity.init(name: String(describing: name), id: String(describing: id), country: String(describing: country), coord: coord)
            citiesList.append(city)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToMain" {
            let destVC = segue.destination as! UINavigationController
            let mainVC = destVC.viewControllers.first as! MainVC
            mainVC.cities = citiesList
        }
    }
   
    
}
