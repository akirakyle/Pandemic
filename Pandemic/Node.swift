//
//  Node.swift
//  pandemic-v2
//
//  Created by Akira Kyle on 9/26/14.
//  Copyright (c) 2014 Akira Kyle. All rights reserved.
//

import Foundation

class Node {
    var classification = String()
    var type = String()
    var value = Int()
    var x = Double()
    var y = Double()
    var shield = Bool()
    var uid = Int()
    
    var nodeCount = Int()
    var friendlyNodeCount = Int()
    
    var playerName = String()
    
    var beginTime = NSDate()
    var formattedTime = String()
    var score = Int()
    
    var pingTimer = NSTimer()
    
    var availableCures = [Int()]
    var projectedValue = Int()
    
    let minigameAnswer = "atcgcta"
    
    func constructInit() -> String {
        var result = "init=1&classification=\(classification)&type=\(type)"
        result = result + "&value=\(value)&x=\(x)&y=\(y)&shield=\(shield)&uid=\(uid)"
        return result
    }
    
    func constructPing() -> String {
        var result = "ping=1&x=\(x)&y=\(y)&uid=\(uid)"
        return result
    }
    
    func constructAlldata() -> String {
        var result = "alldata=1"
        return result
    }
    
    func constructGetscore() -> String {
        var result = "getscore=1"
        return result
    }
    
    func constructSetscore() -> String {
        var result = "setscore=1&name=\(playerName)&score=\(score)"
        return result
    }
    
    func constructSetvalue() -> String {
        var result = "setvalue=1&value=\(value)&uid=\(uid)"
        return result
    }
}