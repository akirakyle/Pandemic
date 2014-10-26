//
//  DataManager.swift
//  pandemic-v2
//
//  Created by Akira Kyle on 9/26/14.
//  Copyright (c) 2014 Akira Kyle. All rights reserved.
//

import Foundation

class DataManager {
    var nodes = [Node]()
    var player = Node()
    var scores = [String()]
    
    lazy private var archivePath: String = {
        let fileManager = NSFileManager.defaultManager()
        let documentsDirecoryURLs = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
        
        let archiveURL = documentsDirecoryURLs.first!.URLByAppendingPathComponent("PandemicSaveData", isDirectory: false)
        
        return archiveURL.path!
        }()
    
    func save() {
        NSKeyedArchiver.archiveRootObject(nodes, toFile: archivePath)
        NSKeyedArchiver.archiveRootObject(player, toFile: archivePath)
    }
    
    private func unarchiveSavedItems() {
        if NSFileManager.defaultManager().fileExistsAtPath(archivePath) {
            let savedNodes = NSKeyedUnarchiver.unarchiveObjectWithFile(archivePath) as [Node]
            nodes = savedNodes
        
            let savedPlayer = NSKeyedUnarchiver.unarchiveObjectWithFile(archivePath) as Node
            player = savedPlayer
        }
    }
    
    init() {
        unarchiveSavedItems()
    }
    
}