//
//  MainViewController.swift
//  MyWeather
//
//  Created by Tong Lin on 5/19/17.
//  Copyright © 2017 TongLin91. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupTableView()
        
        if let currentLocation = locationManager.location{
            // zooming map to user location
            self.mapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)), animated: true)
            
            // using current location to fetch weather data
            APIRequestManager.sharedManager.fetchCurrentWeather(coordinate: currentLocation.coordinate, completion: { (data) in
                // Parsing weather data
                dump(data)
            }, failure: { (err) in
                // Handle api error
                print(err!.localizedDescription)
            })
        }
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "HistoryWeatherTableViewCell", bundle: nil), forCellReuseIdentifier: HistoryWeatherTableViewCell.cellIdentifier)
    }
   
    func setupLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}

//MARK: - Table View delegation
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryWeatherTableViewCell.cellIdentifier, for: indexPath) as! HistoryWeatherTableViewCell
        
        return cell
    }
    
}

//MARK: - Core Location delegation
extension MainViewController: CLLocationManagerDelegate {
    
}





