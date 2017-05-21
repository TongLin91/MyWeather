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
import CoreData

class MainViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var locationManager = CLLocationManager()
    
    var fetchedResultsController: NSFetchedResultsController<Weather>!
    
    var mainContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupTableView()
        initializeFetchedResultsController()
        
        if let currentLocation = locationManager.location{
            // zooming map to user location
            self.mapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)), animated: true)
            
            // using current location to fetch weather data
            APIRequestManager.sharedManager.fetchCurrentWeather(coordinate: currentLocation.coordinate, completion: { (data) in
                // Parsing weather data
                if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                    if let dict = json as? [String: AnyObject]{
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let pc = appDelegate.persistentContainer
                        
                        pc.performBackgroundTask { (context: NSManagedObjectContext) in
                            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                            
                            // insert core data objects
                            // now it goes in the database
                            
                            
                            let entry = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: self.mainContext) as! Weather
                            entry.populate(dict)
                            
                            dump(entry)
                            
                            do {
                                try context.save()
                            }
                            catch let error {
                                print(error)
                            }
                            
                            DispatchQueue.main.async {
                                self.initializeFetchedResultsController()
                                self.tableView.reloadData()
                            }
                            
                        }
                    }
                }
            }, failure: { (err) in
                // Handle api error
                print(err!.localizedDescription)
            })
        }
    }
    
    func initializeFetchedResultsController() {
        let request: NSFetchRequest<Weather> = Weather.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
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

//MARK: - Table View delegation and data source
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            print("No sections in fetchedResultsController")
            return 0
        }
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            print("No sections in fetchedResultsController")
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryWeatherTableViewCell.cellIdentifier, for: indexPath) as! HistoryWeatherTableViewCell
        
        let weather = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = weather.name! + ", " + String(weather.temp)
        return cell
    }
    
}

//MARK: - Core Location delegation
extension MainViewController: CLLocationManagerDelegate {
    
}





