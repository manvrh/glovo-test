//
//  MapVC+MapDelegate.swift
//  GlovoTest
//
//  Created by Manuel Vrhovac on 22/06/2018.
//  Copyright © 2018 Manuel Vrhovac. All rights reserved.
//

import Foundation


extension MapVC {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        regionChanged()
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolygon:
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = self.view.tintColor.withAlphaComponent(0.2)
            return renderer
        default: return MKOverlayRenderer()
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if #available(iOS 11.0, *) {
            switch annotation {
            case is MKPointAnnotation:
                if let view = mapView.dequeueReusableAnnotationView(withIdentifier: "city"){
                    view.clusteringIdentifier = nil
                    return view
                }
                let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "city")
                view.displayPriority = .required
                view.tintColor =  self.view.tintColor
                view.markerTintColor = self.view.tintColor
                view.calloutOffset = CGPoint(x: 0, y: 0)
                view.canShowCallout = false
                view.glyphImage = #imageLiteral(resourceName: "glovo")
                view.clusteringIdentifier = nil
                return view
            default: return nil
            }
        }
        else {
            switch annotation {
            case is MKPointAnnotation:
                let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                view.pinTintColor = self.view.tintColor
                return view
            default: return nil
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation!
        guard let city = cm.cities.filter({ $0.code == annotation.subtitle! }).first else {
            return
        }
        zoomOn(city)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let myLocation = mapView.view(for: mapView.userLocation){
            myLocation.tintColor = #colorLiteral(red: 0, green: 0.4997211576, blue: 0.9672022406, alpha: 1)
            myLocation.isEnabled = false
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        checkInitialLocation()
    }
    
}
