//
//  JSONHandler.swift
//  pandemic-v2
//
//  Created by Akira Kyle on 9/26/14.
//  Copyright (c) 2014 Akira Kyle. All rights reserved.
//

import Foundation
import UIKit

class JSONHandler: NSObject, NSURLConnectionDataDelegate {
    
    var responseData = NSMutableData()
    var JSONresponseData = [NSDictionary]?()
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        if let httpResponse = response as? NSHTTPURLResponse {
            println("HTTP response: \(httpResponse.statusCode)")
            httpResponse.allHeaderFields
        } else {
            println("No HTTP response")
        }
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.responseData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        //println("Connection finished: \(connection)")
        //println(NSString(data: responseData, encoding: NSUTF8StringEncoding))
        JSONresponseData = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers, error: nil) as [NSDictionary]?
        //println(JSONresponseData)
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        switch JSONresponseData![0]["calltype"] as String {
        case "init":
            appDelegate.mainData.player.uid = JSONresponseData![1]["uid"] as Int
        case "ping":
            appDelegate.mainData.player.type = JSONresponseData![1]["type"] as String
            appDelegate.mainData.player.nodeCount = JSONresponseData![3]["nodeCount"]!.integerValue
            appDelegate.mainData.player.friendlyNodeCount = JSONresponseData![4]["friendlyNodeCount"]!.integerValue
            appDelegate.mainData.player.value = JSONresponseData![2]["value"]!.integerValue
            // For minigame
            for (var i = 0; i < appDelegate.mainData.player.friendlyNodeCount; i++) {
                appDelegate.mainData.player.availableCures.append(48)
            }
        case "alldata":
            var count = 0
            for item in JSONresponseData! {
                if (count != 0) {
                    let nodeDictionary = JSONresponseData![count]
                    let node = Node()
                    node.classification = nodeDictionary["classification"]! as String
                    node.type = nodeDictionary["type"]! as String
                    node.value = nodeDictionary["value"]!.integerValue
                    node.x = nodeDictionary["x"]!.doubleValue
                    node.y = nodeDictionary["y"]!.doubleValue
                    node.shield = nodeDictionary["shield"]!.boolValue
                    node.uid = nodeDictionary["uid"]!.integerValue
                    appDelegate.mainData.nodes.append(node)
                }
                count++
            }
        case "getscore":
            appDelegate.mainData.scores = [String]()
            var count = 0
            for item in JSONresponseData! {
                if (count != 0) {
                    var name = item["name"]! as String
                    var score = item["score"]!.integerValue as Int
                    var scoreEntry = "\(name) - \(score) seconds"
                    appDelegate.mainData.scores.append(scoreEntry)
                }
                count++
            }
        default:
            println("Could not recognize case of JSON Data: \(JSONresponseData)")
        }
        self.responseData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didFailWithError data: NSData!) {
        println("Connection failed with error: \(connection) and  data: \(data)")
    }
    
    func makeHTTPPostRequest(jsonString: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://128.237.90.4")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 500)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let conn = NSURLConnection(request: request, delegate:self)
    }
}