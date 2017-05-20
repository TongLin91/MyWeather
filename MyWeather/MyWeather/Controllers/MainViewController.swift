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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "HistoryWeatherTableViewCell", bundle: nil), forCellReuseIdentifier: HistoryWeatherTableViewCell.cellIdentifier)
    }
   

}

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






