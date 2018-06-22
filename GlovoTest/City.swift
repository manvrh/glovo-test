//
//  CityData.swift
//  GlovoTest
//
//  Created by Manuel Vrhovac on 21/06/2018.
//  Copyright © 2018 Manuel Vrhovac. All rights reserved.
//

import Foundation
import Polyline
import RSClipperWrapper
import MapKit


class City: Equatable {
    
    
    public struct Details {
        var currency: String!
        var enabled: Bool!
        var timeZone: String!
        var busy: Bool!
        var languageCode: String!
    }
    
    var name: String!
    var countryCode: String!
    var code: String!
    var workingArea: [String]!
    var details: Details?
        
    
    lazy var annotation: MKAnnotation = {
        let cityAnnotation = MKPointAnnotation.init()
        cityAnnotation.coordinate = center
        cityAnnotation.title = name
        cityAnnotation.subtitle = code
        return cityAnnotation
    }()
    
    lazy var center: CLLocationCoordinate2D = {
        let count = Double(polygons.count)
        let x = polygons.map{ $0.coordinate.latitude }.reduce(0, +)/count
        let y = polygons.map{ $0.coordinate.longitude }.reduce(0, +)/count
        return CLLocationCoordinate2D(latitude: x, longitude: y)
    }()
    
    lazy var coordinateArrays: [[CLLocationCoordinate2D]] = {
        return workingArea.filter{!$0.isEmpty}.compactMap{ Polyline(encodedPolyline: $0).coordinates }
    }()
    
    lazy var polygons: [MKPolygon] = {
        let p = coordinateArrays.map{ MKPolygon(coordinates: $0, count: $0.count)}
        p.forEach{ $0.title = code }
        return p
    }()
    
    lazy var region = {
        return MKCoordinateRegion.init(polygons: coordinateArrays)
    }()
    
    init(name: String, code: String, countryCode: String, workingArea: [String]) {
        self.name = name
        self.code = code
        self.countryCode = countryCode
        self.workingArea = workingArea
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.code == rhs.code
    }
}



