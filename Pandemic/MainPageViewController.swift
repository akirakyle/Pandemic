//
//  MainPageViewController.swift
//  pandemic-v2
//
//  Created by Vivek Sridhar on 9/27/14.
//  Copyright (c) 2014 Akira Kyle. All rights reserved.
//

import Foundation
import UIKit
import Social

class MainPageViewController: UIViewController {
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var timer = NSTimer()
    let radarGreen:UIImage? = UIImage(named: "radarGreen")
    let radarOrange:UIImage? = UIImage(named: "radarOrange")
    let radarRed:UIImage? = UIImage(named: "radarRed")
    var handler = JSONHandler()
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var immunityLevel: UIProgressView!
    
    @IBOutlet weak var dangerIndicator: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timeLabel.text = appDelegate.mainData.player.formattedTime
        createUpdateTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUpdateTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func updateTimer() {
        // Update time alive
        var timeInSeconds = NSDate().timeIntervalSinceDate(appDelegate.mainData.player.beginTime)
        var seconds:Int = Int(timeInSeconds % 60)
        var minutes:Int = Int((timeInSeconds / 60) % 60)
        var hours:Int = Int(timeInSeconds / 3600)
        appDelegate.mainData.player.formattedTime = "\(hours):\(minutes):\(seconds)"
        timeLabel.text = appDelegate.mainData.player.formattedTime
        
        // Check if you've been infected - send notification if so
        if (appDelegate.mainData.player.type == "virus") {
            // Calculates score and sends it to the server
            appDelegate.mainData.player.score = Int(NSDate().timeIntervalSinceDate(appDelegate.mainData.player.beginTime))
            handler.makeHTTPPostRequest(appDelegate.mainData.player.constructSetscore())
            handler.makeHTTPPostRequest(appDelegate.mainData.player.constructGetscore())
            // Kills the background timer processes
            appDelegate.mainData.player.pingTimer.invalidate()
            timer.invalidate()
            // Creates the notification
            var notification = UILocalNotification()
            notification.alertBody = "Oh no! You've been infected!"
            notification.alertAction = "darn..."
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            var alert = UIAlertController(title: "OH NO!", message: "You've been infected!", preferredStyle: UIAlertControllerStyle.Alert)
            var action = UIAlertAction(title: "Start New Game", style: UIAlertActionStyle.Default, handler:{
                action in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            var shareFBAction = UIAlertAction(title: "Share Score on Facebook", style: UIAlertActionStyle.Default, handler: {
                action in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
                var shareWindow = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                shareWindow.setInitialText("I just survived for \(self.appDelegate.mainData.player.score) seconds in Pandemic!")
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(shareWindow, animated: true, completion: nil)
            })
            var shareTwitterAction = UIAlertAction(title: "Share Score on Twitter", style: UIAlertActionStyle.Default, handler: {
                action in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
                var shareWindow = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                shareWindow.setInitialText("I just survived for \(self.appDelegate.mainData.player.score) seconds in Pandemic!")
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(shareWindow, animated: true, completion: nil)
            })
            alert.addAction(shareFBAction)
            alert.addAction(shareTwitterAction)
            alert.addAction(action)
            var currentViewController = UIApplication.sharedApplication().keyWindow!.rootViewController
            while (currentViewController?.presentedViewController != nil) {
                currentViewController = currentViewController?.presentedViewController
            }
            self.presentViewController(alert, animated: true, completion:nil)
            
            //self.dismissViewControllerAnimated(true, completion: {
            //    action in
            //    UIApplication.sharedApplication().keyWindow.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            //})
            
            //UIApplication.sharedApplication().keyWindow.rootViewController?.presentViewController(alert, animated: true, completion: {
            //    action in
            //    self.dismissViewControllerAnimated(true, completion: nil)
            //})
            //currentViewController!.presentViewController(alert, animated: true, completion: nil)
        }
        
        // Update the immunity display
        immunityLevel.progress = Float(appDelegate.mainData.player.value)/100
        
        // Update the indicator display - send notification if in danger
        if (appDelegate.mainData.player.nodeCount < 1) {
            dangerIndicator.image = radarGreen
            //dangerIndicator.image!.animatedImageWithAnimatedGIFData(radarGreen)
            //UIImage.animatedImageWithAnimatedGIFData
        }
        else if (appDelegate.mainData.player.nodeCount < 5) {
            dangerIndicator.image = radarOrange
        }
        else {
            dangerIndicator.image = radarRed
        }
        
    }

}