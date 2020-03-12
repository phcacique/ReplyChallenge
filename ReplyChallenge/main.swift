//
//  main.swift
//  ReplyChallenge
//
//  Created by Pedro Cacique on 12/03/20.
//  Copyright © 2020 Pedro Cacique. All rights reserved.
//

import Foundation


// READING FILE
let pathURL = URL(fileURLWithPath: (NSString(string:"~/Desktop/1_victoria_lake.txt").expandingTildeInPath ))
let s = StreamReader(url: pathURL)
while let line = s?.nextLine() {
    print(line)
}

// MAIN CODE


// SAVING FILE
let sw = StreamWriter(path: (NSString(string:"~/Desktop/1_victoria_lake_output.txt").expandingTildeInPath ))
sw?.write(data: "Hello, World!")

