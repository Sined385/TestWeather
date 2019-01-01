//
//  WeatherBar.swift
//  TestWeather
//
//  Created by mac on 1/1/19.
//  Copyright © 2019 SINED. All rights reserved.
//

import UIKit

@IBDesignable class WeatherBar: UIView {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var weatherIconImage: UIImageView!
    @IBOutlet weak var weakDayLabel: UILabel!
    
    var view: UIView!
    var nibName = "WeatherBar"
    
    @IBInspectable var temperatureText: String {
        get {
            return textLabel.text!
        }
        set(temperatureText) {
            textLabel.text? = temperatureText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func loadFromNib() -> UIView {
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return UIView()
    }
    
    func setup() {
        view = loadFromNib()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = bounds
        textLabel.text = "bbb"
        textLabel.textColor = white
        addSubview(view)
    }
    
    

}
