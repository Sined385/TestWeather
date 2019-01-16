//
//  Protocols.swift
//  TestWeather
//
//  Created by mac on 1/6/19.
//  Copyright © 2019 SINED. All rights reserved.
//

import Foundation

protocol MenuCVCDelegate: class {
    func dataChanged(city: ParseCity)
}

protocol CheckForCityDuplicate: class {
    func checkForDuplicate(city: ParseCity)
}

