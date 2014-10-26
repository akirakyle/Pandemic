//
//  MinigameController.swift
//  pandemic-v2
//
//  Created by Akira Kyle on 9/28/14.
//  Copyright (c) 2014 Akira Kyle. All rights reserved.
//

import Foundation
import UIKit

class minigameViewController: UIViewController, UITextFieldDelegate {
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    @IBOutlet weak var minigameAnswer: UITextField!
    var handler = JSONHandler()
    
    override func viewDidAppear(animated: Bool) {
        if (appDelegate.mainData.player.availableCures.count == 1) {
            // Empty, exit and call warning
            var alert = UIAlertController(title: "No Available Cures", message: "You haven't received any new data yet!", preferredStyle: UIAlertControllerStyle.Alert)
            var action = UIAlertAction(title: "Go Back", style: UIAlertActionStyle.Default, handler: {
                action in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        minigameAnswer.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        println(appDelegate.mainData.player.availableCures) 
    }
    
    func dismissKeyboard() {
        minigameAnswer.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        minigameAnswer.resignFirstResponder()
        if (minigameAnswer.text == appDelegate.mainData.player.minigameAnswer) {
            appDelegate.mainData.player.value += 48
            handler.makeHTTPPostRequest(appDelegate.mainData.player.constructSetvalue())
            appDelegate.mainData.player.availableCures.removeLast()
            var alert = UIAlertController(title: "Congratulations!", message: "Your immunity has increased!", preferredStyle: UIAlertControllerStyle.Alert)
            var action = UIAlertAction(title: "Go Back", style: UIAlertActionStyle.Default, handler: {
                action in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            var alert = UIAlertController(title: "You failed.", message: "Unsuccessful decipher of cure.", preferredStyle: UIAlertControllerStyle.Alert)
            var action = UIAlertAction(title: "Go Back", style: UIAlertActionStyle.Default, handler: {
                action in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        return true
    }
}