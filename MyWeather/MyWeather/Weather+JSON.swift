//
//  Weather+JSON.swift
//  MyWeather
//
//  Created by Tong Lin on 5/19/17.
//  Copyright © 2017 TongLin91. All rights reserved.
//

import Foundation

extension Weather {

    func populate(_ dict: [String: AnyObject]) {
        if let name = dict["name"] as? String {
            self.name = name
        } else {
            print("no Name")
        }
        
        
        if let coor = dict["coord"] as? [String: Any],
            let lon = coor["lon"] as? Double,
            let lat = coor["lat"] as? Double {
            self.lon = lon
            self.lat = lat
        } else {
            print("No Coordinate")
        }
        
        if let main = dict["main"] as? [String: AnyObject],
            let temp = main["temp"] as? Double,
            let humidity = main["humidity"] as? Double {
            self.temp = temp
            self.humidity = humidity
        } else {
            print("No Temperture")
        }
        
        if let weather = dict["weather"] as? [[String: AnyObject]],
            let icon = weather[0]["icon"] as? String {
            self.icon = icon
        } else {
            print("No weather icon")
        }
    }
    
    
}
