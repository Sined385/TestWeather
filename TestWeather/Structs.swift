//
//  Structs.swift
//  TestWeather
//
//  Created by mac on 12/12/18.
//  Copyright © 2018 SINED. All rights reserved.
//

import Foundation

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
