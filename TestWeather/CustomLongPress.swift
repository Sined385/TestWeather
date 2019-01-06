//
//  CustomLongPress.swift
//  TestWeather
//
//  Created by mac on 1/6/19.
//  Copyright © 2019 SINED. All rights reserved.
//

import UIKit

class CustomLongPress: UILongPressGestureRecognizer {
    
    public var cellIndex: Int?
    
    public func setIndex(index: Int) {
        cellIndex = index
    }
    
}
