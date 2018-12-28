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

let requestQ = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)

class WeatherRequest: NSObject {
    
    let key = "fc411ce5be5c4b9985861401d501c0eb"
    
    func weatherRequest(cityToRequest: ParseCity, completion: @escaping (CityWeather) -> Void) {
        let url = "http://api.openweathermap.org/data/2.5/forecast?id=\(cityToRequest.id!)&APPID=\(key)"
        requestQ.async {
            request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response) in
                switch(response.result) {
                case .success(let data):
                    let json = data as! [String : AnyObject]
                    let weatherForCity = self.parseWeather(data: json, city: cityToRequest)
                    mainQ.async {
                        guard let weatherForCity = weatherForCity else { return }
                        completion(weatherForCity)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func parseWeather(data: [String : AnyObject], city: ParseCity) -> CityWeather? {
        let json = data
        let list = json["list"] as? [AnyObject]
        var cityWeather = CityWeather.init(cnt: String(), cod: String(), listOfWeather: [ListOfWeather]())
        guard let cnt = json["cnt"] else { return nil }
        cityWeather.cnt = String.init(describing: cnt)
        guard let cod = json["cod"] else { return nil }
        cityWeather.cod = String.init(describing: cod)
        var listOfWeather = [ListOfWeather]()
        var clouds = Clouds.init(all: String())
        var mainOfWeather = MainOfWeather.init(grndLevel: String(), humidity: String(), pressure: String(), seaLevel: String(), temp: String(), tempKF: String(), tempMax: String(), tempMin: String())
        var weatherDescription = WeatherDescription.init(description: String(), main: String())
        var wind = Wind.init(deg: String(), speed: String())
        var oneDayWeather = ListOfWeather.init(clouds: clouds, dt: String(), dtTxt: String(), mainOfWeather: mainOfWeather, weatherDescription: weatherDescription, wind: wind)
        for i in 0..<list!.count {
            //O for optional
            guard let cloudsO = list?[i]["clouds"] as? AnyObject else { return nil }
            clouds.all = String.init(describing: cloudsO["all"])
            guard let main = list?[i]["main"] as? AnyObject else { return nil }
            mainOfWeather.grndLevel = String.init(describing: main["grnd_level"])
            mainOfWeather.humidity = String.init(describing: main["humidity"])
            mainOfWeather.pressure = String.init(describing: main["pressure"])
            mainOfWeather.seaLevel = String.init(describing: main["sea_level"])
            //mainOfWeather.temp = String.init(describing: main["temp"])
            mainOfWeather.temp = decideOptional(optionalValue: main["temp"]!)
            //mainOfWeather.tempKF = String.init(describing: main["temp_kf"]!)
            mainOfWeather.tempKF = decideOptional(optionalValue: main["temp_kf"]!)
            //mainOfWeather.tempMax = String.init(describing: main["temp_max"]!)
            mainOfWeather.tempMax = decideOptional(optionalValue: main["temp_max"]!)
            //mainOfWeather.tempMin = String.init(describing: main["temp_min"]!)
            mainOfWeather.tempMin = decideOptional(optionalValue: main["temp_min"]!)
            guard let weatherDesc = list?[i]["weather"] as? AnyObject else { return nil }
            weatherDescription.description = String.init(describing: weatherDesc["description"])
            weatherDescription.main = String.init(describing: weatherDesc["main"])
            guard let dtTxt = list?[i]["dt_txt"] else { return nil }
            guard let dt = list?[i]["dt"] else { return nil }
            guard let windO = list?[i]["wind"] as? AnyObject else { return nil }
            wind.deg = String.init(describing: windO["deg"])
            wind.speed = String.init(describing: windO["speed"])
            oneDayWeather.clouds = clouds
            oneDayWeather.dt = String.init(describing: dt)
            oneDayWeather.dtTxt = String.init(describing: dtTxt)
            oneDayWeather.mainOfWeather = mainOfWeather
            oneDayWeather.weatherDescription = weatherDescription
            oneDayWeather.wind = wind
            listOfWeather.append(oneDayWeather)
        }
        cityWeather.listOfWeather = listOfWeather
        return cityWeather
    }
    
    private func decideOptional(optionalValue: Any?) -> String {
        guard let value = optionalValue else { return String() }
        let string = String(describing: value)
        return string
    }
    
    
}





