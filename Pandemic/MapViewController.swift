//
//  MapViewController.swift
//  pandemic-v2
//
//  Created by Akira Kyle on 9/27/14.
//  Copyright (c) 2014 Akira Kyle. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBAction func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    var handler = JSONHandler()
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let baseLocationX = Double(40.442725)
    let baseLocationY = Double(-79.942532)
    let earthRadius:Double = 6371000 // In meters
    let pi = 3.14159265358
    let blueDot:UIImage? = UIImage(named: "blueDot")
    let greenDot:UIImage? = UIImage(named: "greenDot")
    let redDot:UIImage? = UIImage(named: "redDot")
    var annotations = [MapViewAnnotation]()
    
    override func viewDidLoad() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        
        createMapTimer()
        handler.makeHTTPPostRequest(appDelegate.mainData.player.constructAlldata())
    }
    
    func createMapTimer(){
        var timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: "mapTimer", userInfo: nil, repeats: false)
    }
    
    func mapTimer() {
        for node in appDelegate.mainData.nodes {
            var nodeXinDeg = (baseLocationX - ((node.x / (earthRadius*pi))*180))
            var nodeYinDeg = (baseLocationY - ((node.y / (earthRadius*pi))*180))
            
            var annotation = MapViewAnnotation()
            annotation.getCoordinate(nodeXinDeg, longitude: nodeYinDeg)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        
        //let span = MKCoordinateSpan(latitudeDelta: 0.001 as CLLocationDegrees, longitudeDelta: 0.001 as CLLocationDegrees)
        //let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        //mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            let scaledImage:UIImage? = UIImage(CGImage: blueDot!.CGImage, scale: 5, orientation: UIImageOrientation.Up)
            var annotationView = MKAnnotationView()
            annotationView.image = scaledImage
            return annotationView
        }
        else {
            for node in appDelegate.mainData.nodes {
                var nodeXinDeg = (baseLocationX - ((node.x / (earthRadius*pi))*180))
                var nodeYinDeg = (baseLocationY - ((node.y / (earthRadius*pi))*180))
                
                if annotation.coordinate.latitude == nodeXinDeg && annotation.coordinate.longitude == nodeYinDeg  {
                    if node.type == "cure" {
                        let scaledImage:UIImage? = UIImage(CGImage: greenDot!.CGImage, scale: 7, orientation: UIImageOrientation.Up)
                        var annotationView = MKAnnotationView()
                        annotationView.image = scaledImage
                        return annotationView
                    }
                    else if node.type == "virus" {
                        let scaledImage:UIImage? = UIImage(CGImage: redDot!.CGImage, scale: 7, orientation: UIImageOrientation.Up)
                        var annotationView = MKAnnotationView()
                        annotationView.image = scaledImage
                        return annotationView
                    }
                    else {
                        println("node did not have type")
                        return nil
                    }
                }
            }
        }
        return nil
    }
    
    
}