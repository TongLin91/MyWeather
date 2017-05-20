//
//  APIRequestManager.swift
//  MyWeather
//
//  Created by Tong Lin on 5/19/17.
//  Copyright © 2017 TongLin91. All rights reserved.
//

import Foundation

class APIRequestManager {
    
    static let sharedManager = APIRequestManager()
    
    func fetchCurrentWeather(endPoint: URL, completion: @escaping ((Data?)->Void)){
        let request = URLSession(configuration: URLSessionConfiguration.default)
        
        request.dataTask(with: endPoint) {(data: Data?, _, error: Error?) in
            
            if let validData = data{
                completion(validData)
            }else{
                print(error?.localizedDescription ?? "Unknow error during api call - \(endPoint.absoluteString)")
            }
        }.resume()
    }
}
