//
//  CurrentWeatherView.swift
//  MyWeather
//
//  Created by Tong Lin on 5/21/17.
//  Copyright © 2017 TongLin91. All rights reserved.
//

import UIKit

class CurrentWeatherView: UIView {
    let weather: Weather
    
    init(_ weather: Weather) {
        self.weather = weather
        
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewHierarchy(){
        self.addSubview(backImageView)
        backImageView.addSubview(tempLabel)
        backImageView.addSubview(humidityLabel)
        
        // Download weather icon image
        
        
        
        tempLabel.text = String(weather.temp)
        humidityLabel.text = String(weather.humidity)
    }
    
    func configureConstraints() {
        var imageViewConstraints = [NSLayoutConstraint]()
        imageViewConstraints.append(backImageView.topAnchor.constraint(equalTo: self.topAnchor))
        imageViewConstraints.append(backImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        imageViewConstraints.append(backImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor))
        imageViewConstraints.append(backImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor))
        _ = imageViewConstraints.map{ $0.isActive = true }
        
        var tempLabelConstraints = [NSLayoutConstraint]()
        tempLabelConstraints.append(tempLabel.topAnchor.constraint(equalTo: backImageView.topAnchor))
        tempLabelConstraints.append(tempLabel.leadingAnchor.constraint(equalTo: backImageView.leadingAnchor))
        tempLabelConstraints.append(tempLabel.trailingAnchor.constraint(equalTo: backImageView.trailingAnchor))
        _ = tempLabelConstraints.map{ $0.isActive = true }
        
        var humidityLabelConstraints = [NSLayoutConstraint]()
        humidityLabelConstraints.append(humidityLabel.bottomAnchor.constraint(equalTo: backImageView.bottomAnchor))
        humidityLabelConstraints.append(humidityLabel.leadingAnchor.constraint(equalTo: backImageView.leadingAnchor))
        humidityLabelConstraints.append(humidityLabel.trailingAnchor.constraint(equalTo: backImageView.trailingAnchor))
        _ = humidityLabelConstraints.map{ $0.isActive = true }
    }

    lazy var backImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var tempLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    lazy var humidityLabel: UILabel = {
        let view = UILabel()
        return view
    }()
}
