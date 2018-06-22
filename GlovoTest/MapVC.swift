//
//  ViewController.swift
//  GlovoTest
//
//  Created by Manuel Vrhovac on 20/06/2018.
//  Copyright © 2018 Manuel Vrhovac. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RSClipperWrapper
import SwiftyJSON
import SnapKit


class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    // MARK: - IBOUTLETS
    
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailsStack: UIStackView!
    @IBOutlet weak var chooseFromListButton: UIButton!
    @IBOutlet weak var gpsButton: UIButton!
    @IBOutlet weak var proceedButton: UIButton!
    
    // MARK: - PROPERTIES
    
    var geocoder = CLGeocoder()
    
    var currentCity: City?

    var locationManager = CLLocationManager()
    var isInitiallyZoomedToUserLocation = false

    // MARK: Calculated Properties
    
    var detailRows: [UIStackView] { return detailsStack.substacks.flatMap{$0.substacks} }
    var detailLabels: [UILabel] { return detailRows.map{ $0.sublabels[1]} }
    var isCloseUp: Bool { return mapview.region.span.longitudeDelta < 1.0 }
    
    
    // MARK: - VIEWCONTROLLER
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapview.delegate = self
        mapview.showsUserLocation = true
        
        let iv = proceedButton.imageView!
        iv.contentMode = .scaleAspectFit
        var i = proceedButton.image(for: .normal)!
        i = i.withRenderingMode(.alwaysTemplate)
        proceedButton.setImage(i, for: .normal)
        
        flag.isHidden = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        regionChanged()
        getCities()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        if let selectedCity = cm.selectedCity {
            cm.selectedCity = nil
            zoomOn(selectedCity)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - METHODS
    
    func getCities(){
        cm.getCities(){ cities in
            guard let cities = cities else {
                self.noInternet {
                    self.getCities()
                }
                return
            }
            cm.cities = cities
            self.mapview.addAnnotations(cm.cities.map{$0.annotation})
            self.regionChanged()
            self.checkInitialLocation()
        }
    }
    
    func noInternet(completion: @escaping ()->()){
        let alert = UIAlertController(title: "No internet", message: "Please check your internet connection and try again!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: {_ in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    

    
    
    @IBAction func gpsButtonPressed(_ sender: UIButton) {
        gps()
    }
    
    
    func gps(animated: Bool = true, silent: Bool = false){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            // Disable location features
            if !silent {
                let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in Settings to be able to see your location", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Not now", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Open Settings", style: .cancel, handler: {_ in
                    UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                }))
                self.navigationController?.present(alert, animated: true, completion: nil)
            }
            break
        case .authorizedWhenInUse:
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let center = mapview.userLocation.coordinate
            let region = MKCoordinateRegion(center: center, span: span)
            mapview.setRegion(region, animated: animated)
            break
        default:
            break
        }
    }
    
    func checkInitialLocation(){
        if !isInitiallyZoomedToUserLocation && !cm.cities.isEmpty {
            isInitiallyZoomedToUserLocation = true
            gps(animated: false, silent: true)
            regionChanged()
            if currentCity == nil {
                let alert = UIAlertController(title: "Outside of bounds", message: "Seems like Glovo doesn't deliver at your current location. How do you want to select your city?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Map", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "From List", style: .default, handler: {_ in
                    self.presentSelectCity()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func zoomOn(_ city: City){
        let mapView = mapview!
        let annotation = city.annotation
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
        
        let closeCities = cm.cities.filter{$0.center.distance(from: city.center) < 50100 }
        if closeCities.count > 1 && mapView.region.span.longitudeDelta > 1.5 {
            let polygon = closeCities.map{$0.center}
            let center = MKCoordinateRegion.init(polygon: polygon).center
            let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
        }
        else {
            mapView.setRegion(mapView.regionThatFits(city.region), animated: true)
        }
        
        refreshMenu()
    }
    
    
    
    func refreshMenu(){
        
        flag.alpha = currentCity == nil ? 0.5 : 1.0
        flag.isHidden = !isCloseUp

        if currentCity == nil {
            UIView.animate(withDuration: 0.3){
                self.titleLabel.isHidden = true
                self.titleLabel.alpha = 0.0
                self.subtitleLabel.text = self.isCloseUp ? "Sorry, Glovo doesn't deliver here" : "Please select your city"
                self.detailsStack.isHidden = true
                self.detailsStack.alpha = 0.0
                self.proceedButton.superview!.isHidden = true
                self.proceedButton.superview!.alpha = 0.0
                self.view.layoutIfNeeded()
            }
            

        }
        else {
            UIView.animate(withDuration: 0.3){
                self.titleLabel.isHidden = false
                self.titleLabel.alpha = 1.0
                self.detailsStack.isHidden = false
                self.detailsStack.alpha = 1.0
                self.proceedButton.superview!.isHidden = false
                self.proceedButton.superview!.alpha = 1.0
                self.view.layoutIfNeeded()
            }
        }
        
        self.fetchAndFillDetails(for: currentCity)
        
    }
    
    func lookUpAddress(coordinates: CLLocationCoordinate2D){
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        self.geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard self.mapview.centerCoordinate.distance(from: coordinates) == 0 else {
                return
            }
            if error != nil && placemarks == nil {
                if error!.localizedDescription.contains("kCLErrorDomain error 2"){
                    return
                }
                self.noInternet {
                    self.lookUpAddress(coordinates: coordinates)
                }
                return
            }
            guard self.isCloseUp && self.currentCity != nil else {
                return
            }
            if let placemark = placemarks?.first {
                print(placemark)
                mainThread {
                    self.titleLabel.text = placemark.locality ?? "Unknown Location"
                    self.subtitleLabel.text = placemark.name ?? "Unknown Street"
                    self.refreshMenu()
                }
            }
        }
    }
    
    func fetchAndFillDetails(for city: City?){
        guard let city = city else {
            return
        }
        if let cityDetails = city.details {
            fill(cityDetails)
        }
        else if cm.downloading.contains(city.code){
            delay(0.1){
                self.fetchAndFillDetails(for: city)
            }
        }
        else {
            cm.getDetails(for: city){ details in
                mainThread {
                    city.details = details
                    self.fill(details)
                }
            }
        }
    }
    
    func fill(_ cityDetails: City.Details?){
        guard let city = currentCity, let details = cityDetails else {
            return
        }
        let texts = [
            city.countryCode,
            details.languageCode,
            details.currency,
            details.timeZone,
            city.code,
            details.enabled ? "✅" : "❌",
            details.busy ? "✅" : "❌"
        ]
        for (index, label) in self.detailLabels.enumerated(){
            label.text = texts[index]
        }
        if detailsStack.isHidden {
            self.refreshMenu()
        }
        self.view.layoutIfNeeded()
    }
    
    

    func regionChanged(){
        let mapView = self.mapview!
        let pins = mapView.annotations.filter{ $0 is MKPointAnnotation }
        let pinViews = pins.map{ mapView.view(for: $0) }
        pinViews.forEach{ $0?.isHidden = isCloseUp }
        
        self.currentCity = nil
        if isCloseUp {
            for city in cm.cities {
                if mapView.centerCoordinate.distance(from: city.center) < 99400.0 {
                    mapView.addOverlays(city.polygons)
                    if !city.polygons.filter({$0.contains(coordinate: mapView.centerCoordinate)}).isEmpty   {
                        self.currentCity = city
                    }
                }
                else {
                    mapView.removeOverlays(city.polygons)
                }
            }
        }
        else {
            mapView.removeOverlays(cm.cities.flatMap{$0.polygons})
        }
        
        self.refreshMenu()
        lookUpAddress(coordinates: mapView.centerCoordinate)
    }
    
    
    @IBAction func selectCityPressed(_ sender: UIButton) {
        presentSelectCity()
    }
    
    func presentSelectCity(){
        self.performSegue(withIdentifier: "selectCity", sender: nil)
    }
    

    


}

