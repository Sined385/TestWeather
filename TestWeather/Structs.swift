//
//  Structs.swift
//  TestWeather
//
//  Created by mac on 12/12/18.
//  Copyright © 2018 SINED. All rights reserved.
//

import Foundation

struct ParseCity: Codable, Equatable, Hashable {
    var name: String
    var id: String?
    var country: String?
    var coord: ParseCoord?
    var cityWeather: CityWeather?
}

struct ParseCoord: Codable, Equatable, Hashable {
    var lon: String?
    var lat: String?
}

struct Clouds: Codable, Equatable, Hashable {
    var all: String
}

struct MainOfWeather: Codable, Equatable, Hashable {
    var grndLevel: String
    var humidity: String
    var pressure: String
    var seaLevel: String
    var temp: String
    var tempKF: String
    var tempMax: String
    var tempMin: String
}

struct WeatherDescription: Codable, Equatable, Hashable {
    var description: String
    var main: String
}

struct Wind: Codable, Equatable, Hashable {
    var deg: String
    var speed: String
}
struct Rain: Codable, Equatable, Hashable {
    var chance: String
}

struct ListOfWeather: Codable, Equatable, Hashable {
    var clouds: Clouds
    var dt: String
    var dtTxt: String
    var mainOfWeather: MainOfWeather
    var weatherDescription: WeatherDescription
    var wind: Wind
    var rain: Rain
    var weekday: String
}

struct CityWeather: Codable, Equatable, Hashable {
    var cnt: String
    var cod: String
    var listOfWeather: [ListOfWeather]
}


