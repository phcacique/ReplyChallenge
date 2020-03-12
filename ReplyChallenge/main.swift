//
//  main.swift
//  ReplyChallenge
//
//  Created by Pedro Cacique on 12/03/20.
//  Copyright © 2020 Pedro Cacique. All rights reserved.
//

import Foundation


// READING FILE
let pathURL = URL(fileURLWithPath: (NSString(string:"~/Desktop/Reply Challenge/Inputs/a_solar.txt").expandingTildeInPath ))
let s = StreamReader(url: pathURL)
var lineCount = 0
while let line = s?.nextLine() {
    switch lineCount {
    case 0:
        let cut = line.split(separator: " ").map(String.init)
        let width = Int(cut[0])
        let height = Int(cut[1])
        
        break
    default:
        break
    }
    lineCount += 1
}

// MAIN CODE


// SAVING FILE
let sw = StreamWriter(path: (NSString(string:"~/Desktop/1_victoria_lake_output.txt").expandingTildeInPath ))
sw?.write(data: "Hello, World!")

