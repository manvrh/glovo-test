//
//  Extensions.swift
//  GlovoTest
//
//  Created by Manuel Vrhovac on 21/06/2018.
//  Copyright © 2018 Manuel Vrhovac. All rights reserved.
//

import Foundation


extension CLLocationCoordinate2D {
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}


extension MKPolygon {
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPointForCoordinate(coordinate)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        
        return  polygonRenderer.path?.contains(polygonViewPoint) ?? false
    }
}


public func delay(_ seconds: Double, if condition: Bool = true, _ completion: @escaping () -> ()) {
    if condition == false { return }
    if seconds == 0.0 {
        completion()
        return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        mainThread {
            completion()
        }
    }
}



extension MKCoordinateRegion {
    init(polygons: [[CLLocationCoordinate2D]]){
        let coordinatePolygons = polygons
        let lats = coordinatePolygons.flatMap{ c in c.map{$0.latitude} }
        let lons = coordinatePolygons.flatMap{ c in c.map{$0.longitude} }
        let center = CLLocationCoordinate2D(latitude: (lats.max()!+lats.min()!)/2, longitude: (lons.max()!+lons.min()!)/2)
        let span = MKCoordinateSpan(latitudeDelta: abs(lats.max()!-lats.min()!)*1.1, longitudeDelta: abs(lons.max()!-lons.min()!)*1.1)
        self = MKCoordinateRegion(center: center, span: span)
        
    }
    
    init(polygon: [CLLocationCoordinate2D]){
        self = MKCoordinateRegion.init(polygons: [polygon])
    }
}



extension UIStackView {
    var substacks: [UIStackView] {
        return self.arrangedSubviews.filter{ $0 is UIStackView } as! [UIStackView]
    }
    
    var sublabels: [UILabel]{
        return self.arrangedSubviews.filter{ $0 is UILabel } as! [UILabel]
    }
}

extension String {
    
    static func flagEmojiForCountryCode(_ countryCode: String) -> String {
        var string = ""
        var country = countryCode.uppercased()
        for uS in country.unicodeScalars {
            string += String(UnicodeScalar(127397 + uS.value)!)
        }
        return string
    }

}

