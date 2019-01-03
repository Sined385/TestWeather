//
//  WeatherBarButton.swift
//  TestWeather
//
//  Created by mac on 1/3/19.
//  Copyright © 2019 SINED. All rights reserved.
//

import UIKit

class WeatherBarButton: UIButton {
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var view: UIView!
    var nibName = "WeatherBarButton"
    
    private func loadFromNib() -> UIView {
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    func setup() {
        view = loadFromNib()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = bounds
        temperatureLabel.textColor = white
        weekdayLabel.textColor = white
        view.isUserInteractionEnabled = false
        addSubview(view)
    }
    
    

}
