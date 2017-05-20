//
//  APIRequestManager.swift
//  MyWeather
//
//  Created by Tong Lin on 5/19/17.
//  Copyright © 2017 TongLin91. All rights reserved.
//

import Foundation
import CoreLocation

class APIRequestManager {
    
    static let sharedManager = APIRequestManager()
    private let apiKey = "766f5884a7ce4b8d39e015457a472ff3"
    
    func fetchCurrentWeather(coordinate: CLLocationCoordinate2D, completion: @escaping (Data?)->Void, failure: @escaping (Error?) -> Void){
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=imperial&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)")!
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                failure(error)
            }
            
            if data != nil{
                completion(data)
            }
        }.resume()
    }
}
