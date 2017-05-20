//
//  Weather.swift
//  MyWeather
//
//  Created by Tong Lin on 5/19/17.
//  Copyright © 2017 TongLin91. All rights reserved.
//

import Foundation

class Weather {
    var lon: Double?
    var lat: Double?
    var name: String?
    var temp: Double?
    var humidity: Double?
    var icon: String?
    
    init(dict: [String: AnyObject]) {
        self.name = dict["name"] as? String
        
        if let coor = dict["coord"] as? [String: Double] {
            self.lon = coor["lon"]
            self.lat = coor["lat"]
        }
        
        if let main = dict["main"] as? [String: Double] {
            self.temp = main["temp"]
            self.humidity = main["humidity"]
        }
        
        if let weather = dict["weather"] as? [[String: AnyObject]] {
            self.icon = weather[0]["icon"] as? String
        }
    }
    
    
}
