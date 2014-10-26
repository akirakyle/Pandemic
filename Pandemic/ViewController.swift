//
//  ViewController.swift
//  pandemic-v2
//
//  Created by Akira Kyle on 9/26/14.
//  Copyright (c) 2014 Akira Kyle. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var handler = JSONHandler()
    let myLocationManager = CLLocationManager()
    var myLocations = [CLLocation]()
    var currentLocation = CLLocation()
    let baseLocationX = Double(40.442725)
    let baseLocationY = Double(-79.942532)
    let earthRadius:Double = 6371000 // In meters
    let pi = 3.14159265358

    @IBOutlet weak var nameField: UITextField!
    
    @IBAction func nameFieldConfirm(sender: AnyObject) {
        nameField.delegate = self
        nameField.resignFirstResponder()
    }
    
    @IBAction func thisButton(sender: AnyObject) {
        appDelegate.mainData.player = Node()
        appDelegate.mainData.nodes = [Node]()
        // Initialize player
        appDelegate.mainData.player.classification = "player"
        appDelegate.mainData.player.type = "cure"
        appDelegate.mainData.player.value = 60
        appDelegate.mainData.player.x = 432.321
        appDelegate.mainData.player.y = 231.412
        appDelegate.mainData.player.shield = false
        appDelegate.mainData.player.playerName = nameField.text
        handler.makeHTTPPostRequest(appDelegate.mainData.player.constructInit())
        appDelegate.mainData.player.beginTime = NSDate()
        // Initialize location services
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.distanceFilter = kCLDistanceFilterNone
        myLocationManager.requestAlwaysAuthorization()
        myLocationManager.delegate = self
        myLocationManager.startUpdatingLocation()
        // Start background ping routine
        createPingTimer()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.currentLocation = locations[locations.endIndex - 1] as CLLocation
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    func createPingTimer(){
        appDelegate.mainData.player.pingTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(5), target: self, selector: "pingTimer", userInfo: nil, repeats: true)
    }
    
    func pingTimer() {
        myLocationManager.stopUpdatingLocation()
        myLocationManager.startUpdatingLocation()
        // Calculate distance from baseLocation for (x,y) as meters
        var dx = baseLocationX - currentLocation.coordinate.latitude
        var dy = baseLocationY - currentLocation.coordinate.longitude
        var distanceX = ((dx*pi) / 180) * earthRadius
        var distanceY = ((dy*pi) / 180) * earthRadius
        appDelegate.mainData.player.x = distanceX
        appDelegate.mainData.player.y = distanceY
        handler.makeHTTPPostRequest(appDelegate.mainData.player.constructPing())
        //println(appDelegate.mainData.player.value)
        println(appDelegate.mainData.player.nodeCount)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        nameField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        handler.makeHTTPPostRequest(appDelegate.mainData.player.constructGetscore())
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Do any initialization before switching to next view
    }


}

