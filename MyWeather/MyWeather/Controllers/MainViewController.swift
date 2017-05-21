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

class MainViewController: UIViewController, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var locationManager = CLLocationManager()
    
    var fetchedResultsController: NSFetchedResultsController<Weather>!
    
    var mainContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    var currentWeather: Weather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupLocationManager()
        setupTableView()
        initializeFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let currentLocation = locationManager.location{
            // zooming map to user location
            self.mapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)), animated: true)
            
            self.getCurrentWeather(currentLocation.coordinate)
        }
    }
    
    func initializeFetchedResultsController() {
        let request: NSFetchRequest<Weather> = Weather.fetchRequest()
        let sort = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [sort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func getCurrentWeather(_ coor: CLLocationCoordinate2D){
        // using current location to fetch weather data
        APIRequestManager.sharedManager.fetchCurrentWeather(coordinate: coor, completion: { (data) in
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
                        self.currentWeather = entry
                        
                        _ = self.isExist(data: entry)
                        
                        appDelegate.saveContext()
                        
                        DispatchQueue.main.sync {
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
    
    // Remove duplicate coordinates
    func isExist(data: Weather) -> Bool {
        let request: NSFetchRequest<Weather> = Weather.fetchRequest()
        let sort = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "id == %u", data.id)
        
        let res = try! mainContext.fetch(request)
        if res.count > 1 {
            self.mainContext.delete(res.last!)

            return true
        } else {
            return false
        }
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "HistoryWeatherTableViewCell", bundle: nil), forCellReuseIdentifier: HistoryWeatherTableViewCell.cellIdentifier)
    }
   
    func setupLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}

// MARK: - Table View delegation and data source
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
        // Set maximum number of rows to 5
        return sectionInfo.numberOfObjects > 6 ? 5 : sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryWeatherTableViewCell.cellIdentifier, for: indexPath) as! HistoryWeatherTableViewCell
        
        let weather = fetchedResultsController.object(at: indexPath)
        
        // Update weather data for history coordinates
        APIRequestManager.sharedManager.fetchCurrentWeather(coordinate: CLLocationCoordinate2D(latitude: weather.lat, longitude: weather.lon), completion: { (data) in
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let dict = json as? [String: AnyObject]{
                    
                    weather.populate(dict)
                        
                    DispatchQueue.main.async {
                        cell.nameLabel.text = weather.name ?? ""
                        cell.tempLabel.text = "Temp: \(weather.temp)"
                        cell.humLabel.text = "Humidity: \(weather.humidity)"
                    }
                    
                    APIRequestManager.sharedManager.fetchWeatherIcon(name: weather.icon!, completion: { (data) in
                        DispatchQueue.main.async {
                            cell.iconImageView.image = UIImage(data: data!)
                        }
                    }, failure: { (err) in
                        // Handle error
                        print(err!.localizedDescription)
                    })
                    
                }
            }
        
        }) { (err) in
            // Handle api error
            print(err!.localizedDescription)
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height/4.2
    }
    
}

// MARK: - MK MapView delegation
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Add popup accessory views when user tapped on current location indicator
        if let info = currentWeather{
            
            // Center Image
            APIRequestManager.sharedManager.fetchWeatherIcon(name: info.icon!, completion: { (data) in
                view.detailCalloutAccessoryView = UIImageView(image: UIImage(data: data!, scale: 0.5))
            }, failure: { (err) in
                // Handle error
                print(err!.localizedDescription)
            })
            
            // Left Accessory
            let leftAccessory = UILabel(frame: CGRect(x: 0,y: 0,width: 50,height: 30))
            leftAccessory.text = "Temp\n\(info.temp)"
            leftAccessory.numberOfLines = 2
            leftAccessory.textAlignment = .center
            leftAccessory.font = UIFont(name: "Verdana", size: 10)
            view.leftCalloutAccessoryView = leftAccessory
            
            // Right Accessory
            let rightAccessory = UILabel(frame: CGRect(x: 0,y: 0,width: 50,height: 30))
            rightAccessory.text = "Humidity\n\(info.humidity)"
            rightAccessory.numberOfLines = 2
            rightAccessory.textAlignment = .center
            rightAccessory.font = UIFont(name: "Verdana", size: 10)
            view.rightCalloutAccessoryView = rightAccessory
        }
    }
}





