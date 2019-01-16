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
    
    private let key = "fc411ce5be5c4b9985861401d501c0eb"
    
    public func weatherRequest(cityToRequest: ParseCity, completion: @escaping (CityWeather) -> Void) {
        let url = "http://api.openweathermap.org/data/2.5/forecast?id=\(cityToRequest.id!)&APPID=\(key)"
        requestQ.async {
            request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response) in
                switch(response.result) {
                case .success(let data):
                    let json = data as! [String : AnyObject]
                    let weatherForCity = self.parseWeather(data: json)
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
    
    private func parseWeather(data: [String : AnyObject]) -> CityWeather? {
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
        var rain = Rain.init(chance: String())
        var weekday = String()
        var oneDayWeather = ListOfWeather.init(clouds: clouds, dt: String(), dtTxt: String(), mainOfWeather: mainOfWeather, weatherDescription: weatherDescription, wind: wind, rain: rain, weekday: weekday)
        for i in 0..<list!.count {
            //O for optional
            guard let cloudsO = list?[i]["clouds"] as? AnyObject else { return nil }
            clouds.all = String.init(describing: cloudsO["all"])
            guard let main = list?[i]["main"] as? AnyObject else { return nil }
            mainOfWeather.grndLevel = String.init(describing: main["grnd_level"])
            mainOfWeather.humidity = decideOptional(optionalValue: main["humidity"]!)
            mainOfWeather.pressure = decideOptional(optionalValue: main["pressure"]!)
            mainOfWeather.seaLevel = decideOptional(optionalValue: main["sea_level"]!)
            mainOfWeather.temp = decideOptional(optionalValue: main["temp"]!)
            mainOfWeather.tempKF = decideOptional(optionalValue: main["temp_kf"]!)
            mainOfWeather.tempMax = decideOptional(optionalValue: main["temp_max"]!)
            mainOfWeather.tempMin = decideOptional(optionalValue: main["temp_min"]!)
            guard let weatherDesc = list![i]["weather"] as? [AnyObject] else { return nil }
            guard let mainDescription = weatherDesc[0]["main"] else { return nil }
            weatherDescription.description = decideOptional(optionalValue: weatherDesc[0]["description"]!)
            weatherDescription.main = decideOptional(optionalValue: mainDescription)
            guard let dtTxt = list?[i]["dt_txt"] else { return nil }
            guard let dt = list?[i]["dt"] else { return nil }
            guard let windO = list?[i]["wind"] as? AnyObject else { return nil }
            wind.deg = String.init(describing: windO["deg"])
            wind.speed = decideOptional(optionalValue: windO["speed"]!)
            guard let rainO = list?[i]["rain"] as? AnyObject else { return nil }
            rain.chance = decideOptional(optionalValue: rainO["3h"])
            oneDayWeather.clouds = clouds
            oneDayWeather.dt = decideOptional(optionalValue: dt)
            oneDayWeather.dtTxt = decideOptional(optionalValue: dtTxt)
            oneDayWeather.mainOfWeather = mainOfWeather
            oneDayWeather.weatherDescription = weatherDescription
            oneDayWeather.wind = wind
            oneDayWeather.rain = rain
            weekday = makeWeekDay(dayNumber: getDayOfWeek(convertUnixDate(oneDayWeather.dt))!)
            oneDayWeather.weekday = weekday
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
    
    private func convertUnixDate(_ unixTimeStamp: String) -> String {
        let date = Date(timeIntervalSince1970: Double(unixTimeStamp)!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    private func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    private func makeWeekDay(dayNumber: Int) -> String {
        switch dayNumber {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return ""
        }
    }
    
}


//Adding options to make request of city by coordinates

extension WeatherRequest {
    
    public func requestByCoordinates(lon: String, lat: String, completionCoord: @escaping (ParseCity) -> Void) {
        let url = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&APPID=\(key)"
        requestQ.async {
            request(url, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseJSON(completionHandler: { (response) in
                switch(response.result) {
                case .success(let data):
                    let json = data as! [String : AnyObject]
                    var city = self.makeCityFromGotWithCoord(json: json, lon: lon, lat: lat)!
                    self.weatherRequest(cityToRequest: city, completion: { (cityWeather) in
                        city.cityWeather = cityWeather
                        mainQ.async {
                            completionCoord(city)
                        }
                    })
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    private func makeCityFromGotWithCoord(json: [String : AnyObject], lon: String, lat: String) -> ParseCity? {
        guard let name = json["name"] else { return nil }
        guard let id = json["id"] else { return nil }
        guard let country = json["sys"]?["country"] else { return nil }
        let coord = ParseCoord.init(lon: lon, lat: lat)
        let city = ParseCity.init(name: name as! String, id: String.init(describing: id), country: country as? String, coord: coord, cityWeather: nil)
        return city
    }
    
}




