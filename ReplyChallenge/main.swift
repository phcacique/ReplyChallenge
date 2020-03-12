//
//  main.swift
//  ReplyChallenge
//
//  Created by Pedro Cacique on 12/03/20.
//  Copyright © 2020 Pedro Cacique. All rights reserved.
//

import Foundation

protocol Person{
    var company:String{get set}
    var bonus:Int{get set}
}

struct Developer:Person{
    var company:String
    var bonus:Int
    var skillsNum:Int
    var skills:[String]
}

struct PM:Person{
    var company:String
    var bonus:Int
}

struct Gene{
    var type:Int
    var person:Person
    var score:Int
}

class Cell{
    var x:Int
    var y:Int
    var type:String
    var count:Int
    var neighbors:[Cell] = []
    var person:Person?
    
    init(x:Int, y:Int, type:String, count:Int){
        self.x = x
        self.y = y
        self.type = type
        self.count = count
    }
}

let files:[String] = ["a_solar", "b_dream", "c_soup", "d_maelstrom", "e_igloos", "f_glitch"]
let activeFile:Int = 1

// READING FILE
let pathURL = URL(fileURLWithPath: (NSString(string:"~/Desktop/\(files[activeFile]).txt").expandingTildeInPath ))
let s = StreamReader(url: pathURL)
var lines:[String] = []
while let line = s?.nextLine() {
//    print(line)
    lines.append(line)
}

//MAIN CODE

// --- PARSING INPUT ---
// Office size
var size:(width:Int, height:Int)
let x = lines[0].split(separator: " ").map(String.init)
size.width = Int(x[0])!
size.height = Int(x[1])!

//Available cells and matrix
var availableCellsCount = 0
var devCount:Int = 0
var pmCount:Int = 0
var availableCells:[Cell] = []

var tdc:Int = 0
var tpc:Int = 0
for i in 1...size.height{
    let text = lines[i]
    let devChar: Character = "_"
    let pmChar: Character = "M"
    devCount += text.filter { $0 == devChar }.count
    pmCount += text.filter { $0 == pmChar }.count
    availableCellsCount += devCount
    availableCellsCount += pmCount
    
    //getting neighbours
    
    for j in 0..<text.count{
        let v = String(Array(text)[j])
        if v=="_"{
            availableCells.append(Cell(x: j, y: i, type: v , count: tdc ))
            tdc += 1
        } else if v=="M"{
            availableCells.append(Cell(x: j, y: i, type: v , count: tpc ))
            tpc += 1
        }
    }
}

func getCellIndex(from list:[Cell], x:Int, y:Int) -> Int{
    var ind = -1
    for i in 0..<list.count{
        if list[i].x == x && list[i].y == y {
            ind = i
        }
    }
    return ind
}

func getNeighbors(_ c:Cell) -> [Cell]{
    var n:[Cell] = []
    var ind = getCellIndex(from: availableCells, x: c.x, y: c.y-1)
    if c.y > 0 && ind>=0 { //TOP
        n.append(availableCells[ind])
    }
    
    ind = getCellIndex(from: availableCells, x: c.x, y: c.y+1)
    if c.y < size.height-1 && ind>=0 { //BOTTOM
        n.append(availableCells[ind])
    }
    
    ind = getCellIndex(from: availableCells, x: c.x-1, y: c.y)
    if c.x > 0 && ind>=0 { //left
        n.append(availableCells[ind])
    }
    
    ind = getCellIndex(from: availableCells, x: c.x+1, y: c.y)
    if c.x < size.width-1 && ind>=0 { //right
        n.append(availableCells[ind])
    }
    return n
}

for i in 0..<availableCells.count{
    var c = availableCells[i]
    c.neighbors = getNeighbors(c)
}

print("Available cells count: \(availableCellsCount)")


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

// --- GENETIC ALGORITHM ---
func genChromosome() -> [Cell]{
    var tempDev = devs.shuffled()
    var tempPM = devs.shuffled()
    var chromosome:[Cell] = []
    chromosome.append(contentsOf: availableCells)
    
    for i in 0..<chromosome.count{
        if chromosome[i].type == "_"{
            chromosome[i].person = tempDev.last!
            tempDev.removeLast()
        } else {
            chromosome[i].person = tempDev.last!
            tempDev.removeLast()
        }
    }
    return chromosome
}

func scoreChromossome(_ chrom:[Cell]) -> Int{
    var score:Int = 0
    for g in chrom{
        for n in g.neighbors{
            var tp:Int = 0
            var wp:Int = 0
            if g.type == "_" && n.type == "_" {
                let commonSkills = (g.person as! Developer).skills.filter{ (n.person as! Developer).skills.contains($0) }
                wp += commonSkills.count
                let distinctSkills = (g.person as! Developer).skills.count + (n.person as! Developer).skills.count - 2 * commonSkills.count
                wp *= distinctSkills
            }
            var bp:Int = 0
            if g.person!.company == n.person!.company {
                bp = g.person!.bonus * n.person!.bonus
            }
            tp = wp + bp
            score += tp
        }
    }
    return score
}

let POP_SIZE:Int = 50
let GEN:Int = 10
let MUT:Double = 0.001
let GREADYCOUNT:Int = 10


func genPopulation(size:Int) -> [(c:[Cell], s:Int)]{
    var pop:[(c:[Cell], s:Int)] = []
    
    for i in 0..<size{
        let c = genChromosome()
        let s = scoreChromossome(c)
        pop.append( (c:c, s:s) )
    }
    return pop
}

func checkChrom(_ ch:[Cell]) -> Bool{
    var isValid = true
    for i in 0..<ch.count{
        for j in i..<ch.count{
            if ch[i].x == ch[j].x && ch[i].y == ch[j].y{
                isValid = false
                return isValid
            }
        }
    }
    return isValid
}

func crossover(c1:[Cell], c2:[Cell]) -> (n1:(c:[Cell], s:Int), n2:(c:[Cell], s:Int)){
    var content:(n1:(c:[Cell], s:Int), n2:(c:[Cell], s:Int)) = (n1:(c:c1, s:scoreChromossome(c1)), n2:(c:c2, s:scoreChromossome(c2)))
    
    var p:Int = Int.random(in: 0..<c1.count)
    var cp1:[Cell] = []
    var cp2:[Cell] = []
    
    for i in 0..<p{
        cp1.append(c1[i])
        cp2.append(c2[i])
    }
    for i in p..<c1.count{
        cp2.append(c1[i])
        cp1.append(c2[i])
    }
    
    if checkChrom(cp1){
        content.n1 = (c:cp1, s:scoreChromossome(cp1))
    }
    if checkChrom(cp2){
        content.n2 = (c:cp2, s:scoreChromossome(cp2))
    }
    
    return content
}


func mutate(ch:[Cell]) -> (c:[Cell], s:Int){
    var n:(c:[Cell], s:Int) = (c:ch, s:scoreChromossome(ch))
    var dP:Int = Int.random(in: 0..<devCount)
    
    var nC = devs[dP]
    var rC = nC
    repeat{
        rC = devs[ Int.random(in: 0..<devs.count) ]
    } while (nC.company != rC.company && nC.bonus != rC.bonus && nC.skills != rC.skills)
    
    var ch2:[Cell] = []
    ch2.append(contentsOf: ch)
    ch2[dP].person = rC
    
    n.c = ch2
    n.s = scoreChromossome(n.c)
    
    return n
}


func getBest(pop:[(c:[Cell], s:Int)]) -> (c:[Cell], s:Int){
    var newPop = pop.sorted(by: { $0.s > $1.s })
    return newPop[0]
}

var pop:[(c:[Cell], s:Int)] = []
for i in 0..<GEN{
    //generate population
    if i==0 {
        pop = genPopulation(size: POP_SIZE)
    } else {
        // GREADY
        var firsts:[(c:[Cell], s:Int)] = []
        for i in 0..<GREADYCOUNT{
            firsts.append(pop[i])
        }
        pop = genPopulation(size: POP_SIZE)
        for i in 0..<firsts.count{
            pop[i] = firsts[i]
        }
//        pop = genPopulation(size: POP_SIZE)
    }
    
    //crossover
    var newPop:[(c:[Cell], s:Int)] = []
    for i in 0..<POP_SIZE/2{
        var chroms:(n1:(c:[Cell], s:Int), n2:(c:[Cell], s:Int)) = crossover(c1: pop[i].c, c2: pop[i + POP_SIZE/2].c)
        newPop.append(chroms.n1)
        newPop.append(chroms.n2)
    }
    
    //mutation
    for i in 0..<POP_SIZE{
        if Double.random(in: 0...1)>MUT {
            newPop[i] = mutate(ch: newPop[i].c)
        }
    }
    
    pop = newPop.sorted(by: { $0.s > $1.s })
    
    
    print (getBest(pop: pop).s)
}

let sw = StreamWriter(path: (NSString(string:"~/Desktop/\(files[activeFile]).txt").expandingTildeInPath ))
for d in devs{
    var ind0:Int = -1
    var ind = -1
    for i in 0..<pop.count{
        
        for j in 0..<pop[i].c.count{
            if d.company == pop[i].c[j].person!.company && d.bonus == pop[i].c[j].person!.bonus{
                ind = j
                ind0 = i
            }
        }
    }
    if ind != -1 {
        sw?.writeLine(data: "\(pop[ind0].c[ind].x) \(pop[ind0].c[ind].y)")
    } else {
        sw?.writeLine(data: "X")
    }
}
for d in pms{
    var ind0:Int = -1
    var ind = -1
    for i in 0..<pop.count{
        var ind = -1
        for j in 0..<pop[i].c.count{
            if d.company == pop[i].c[j].person!.company && d.bonus == pop[i].c[j].person!.bonus{
                ind = j
            }
        }
        
    }
    if ind != -1 {
        sw?.writeLine(data: "\(pop[ind0].c[ind].x) \(pop[ind0].c[ind].y)")
    } else {
        sw?.writeLine(data: "X")
    }
}



// SAVING FILE
//let sw = StreamWriter(path: (NSString(string:"~/Desktop/a_solar_output.txt").expandingTildeInPath ))
//sw?.write(data: "Hello, World!")

