//
//  Structs.swift
//  TestWeather
//
//  Created by mac on 12/12/18.
//  Copyright © 2018 SINED. All rights reserved.
//

import Foundation

struct ParseCity: Codable {
    var name: String
    var id: String?
    var country: String?
    var coord: ParseCoord?
    var cityWeather: CityWeather?
}

struct ParseCoord: Codable {
    var lon: String?
    var lat: String?
}

struct Clouds: Codable {
    var all: String
}

struct MainOfWeather: Codable {
    var grndLevel: String
    var humidity: String
    var pressure: String
    var seaLevel: String
    var temp: String
    var tempKF: String
    var tempMax: String
    var tempMin: String
}

struct WeatherDescription: Codable {
    var description: String
    var main: String
}

struct Wind: Codable {
    var deg: String
    var speed: String
}

struct ListOfWeather: Codable {
    var clouds: Clouds
    var dt: String
    var dtTxt: String
    var mainOfWeather: MainOfWeather
    var weatherDescription: WeatherDescription
    var wind: Wind
}

struct CityWeather: Codable {
    var cnt: String
    var cod: String
    var listOfWeather: [ListOfWeather]
}


