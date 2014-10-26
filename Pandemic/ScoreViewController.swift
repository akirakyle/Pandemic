//
//  ScoreViewController.swift
//  pandemic-v2
//
//  Created by Akira Kyle on 9/28/14.
//  Copyright (c) 2014 Akira Kyle. All rights reserved.
//

import Foundation
import UIKit

class scoreViewController: UITableViewController {
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var handler = JSONHandler()
    
    @IBAction func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeScoreView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handler.makeHTTPPostRequest(appDelegate.mainData.player.constructGetscore())
        var indexPaths = [NSIndexPath]()
        var counter = 0
        for score in appDelegate.mainData.scores {
            let indexPath = NSIndexPath(forRow: counter, inSection: 0)
            indexPaths.append(indexPath)
            counter++
        }
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mainData.scores.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListViewCell") as UITableViewCell
        let cellEntry = appDelegate.mainData.scores[indexPath.row]
        cell.textLabel.text = cellEntry
        
        return cell
    }
}