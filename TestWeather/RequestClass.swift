//
//  RequestClass.swift
//  TestWeather
//
//  Created by mac on 12/26/18.
//  Copyright © 2018 SINED. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherRequest: NSObject {
    
    let key = "fc411ce5be5c4b9985861401d501c0eb"
    
    func weatherRequest(city: ParseCity) {
        let url = "http://api.openweathermap.org/data/2.5/forecast?id=\(city.id!)&APPID=\(key)"
        request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response) in
            switch(response.result) {
            case .success(let data):
                print(data)
                do {
                    let json = try JSON(data: data as! Data)
                    //print(json["city"]["id"])
                } catch let error as NSError{
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
            
        }
        
    }
    
    func parseWeather(data: [String : AnyObject]) {
        
    }
    
    
}
