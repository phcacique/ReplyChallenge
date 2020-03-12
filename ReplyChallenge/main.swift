//
//  main.swift
//  ReplyChallenge
//
//  Created by Pedro Cacique on 12/03/20.
//  Copyright © 2020 Pedro Cacique. All rights reserved.
//

import Foundation

struct Developer{
    var company:String
    var bonus:Int
    var skillsNum:Int
    var skills:[String]
}

struct PM{
    var company:String
    var bonus:Int
}

let files:[String] = ["a_solar", "b_dream", "c_soup", "d_maelstrom", "e_igloos", "f_glitch"]
let activeFile:Int = 0

// READING FILE
let pathURL = URL(fileURLWithPath: (NSString(string:"~/Desktop/\(files[activeFile]).txt").expandingTildeInPath ))
let s = StreamReader(url: pathURL)
var lines:[String] = []
while let line = s?.nextLine() {
//    print(line)
    lines.append(line)
}

//MAIN CODE

// Office size
var size:(width:Int, height:Int)
let x = lines[0].split(separator: " ").map(String.init)
size.width = Int(x[0])!
size.height = Int(x[1])!

//Available cells
var availableCells = 0
for i in 1...size.height{
    let text = lines[i]
    let devChar: Character = "_"
    let pmChar: Character = "M"
    let devCount = text.filter { $0 == devChar }.count
    let pmCount = text.filter { $0 == pmChar }.count
    availableCells += devCount
    availableCells += pmCount
}
print("Available cells: \(availableCells)")

//List of developers
var cursor:Int = size.height+1
let numDevs:Int =  Int(lines[cursor])!
print("Number of developers: \(numDevs)")
cursor += 1

var devs:[Developer] = []
for i in cursor..<(cursor+numDevs){
    let info = lines[i].split(separator: " ").map(String.init)
    var skills:[String] = []
    for j in 3..<info.count{
        skills.append(info[j])
    }
    devs.append(Developer(company: info[0], bonus: Int(info[1])!, skillsNum: Int(info[2])!, skills: skills))
    cursor+=1
}

//List of project managers
let numPMs:Int =  Int(lines[cursor])!
print("Number of project managers: \(numPMs)")
cursor+=1

var pms:[PM] = []
for i in cursor..<(cursor+numPMs){
    let info = lines[i].split(separator: " ").map(String.init)
    pms.append(PM(company: info[0], bonus: Int(info[1])!))
    cursor+=1
}





// SAVING FILE
//let sw = StreamWriter(path: (NSString(string:"~/Desktop/a_solar_output.txt").expandingTildeInPath ))
//sw?.write(data: "Hello, World!")

