//
//  main.swift
//  ReplyChallenge
//
//  Created by Pedro Cacique on 12/03/20.
//  Copyright © 2020 Pedro Cacique. All rights reserved.
//

import Foundation

extension CustomStringConvertible{
    var description:String{
        var str = "\(type(of: self)){ "
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children{
            if let propertyName = child.label{
                str += "\(propertyName): \(child.value); "
            }
        }
        str += "}"
        return str
    }
}


protocol Person{
    var id:Int{get set}
    var company:String{get set}
    var bonus:Int{get set}
}

class Developer:Person, CustomStringConvertible {
    var id:Int
    var company:String
    var bonus:Int
    var skillsNum:Int
    var skills:[String]
    
    init(id:Int, company:String, bonus:Int, skillsNum:Int, skills:[String]) {
        self.id = id
        self.company = company
        self.bonus = bonus
        self.skillsNum = skillsNum
        self.skills = skills
    }
}

class PM:Person, CustomStringConvertible {
    var id:Int
    var company:String
    var bonus:Int
    
    init(id:Int, company:String, bonus:Int) {
        self.id = id
        self.company = company
        self.bonus = bonus
    }
}

class Cell: CustomStringConvertible{
    var id:Int
    var pos:(x:Int, y:Int)
    var type:String
    var neighbors:[Int]
    
    init(id:Int, pos:(x:Int, y:Int), type:String) {
        self.id = id
        self.pos = pos
        self.type = type
        self.neighbors = []
    }
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

// --- PARSING INPUT ---
// Office size
var size:(width:Int, height:Int)
let x = lines[0].split(separator: " ").map(String.init)
size.width = Int(x[0])!
size.height = Int(x[1])!

// Available cells and matrix
var availableCellsCount = 0
var devCount:Int = 0
var pmCount:Int = 0
var availableCells:[Cell] = []

for i in 1...size.height{
    let text = lines[i]
    let devChar: Character = "_"
    let pmChar: Character = "M"
    devCount += text.filter { $0 == devChar }.count
    pmCount += text.filter { $0 == pmChar }.count
    for j in 0..<Array(lines[i]).count{
        if Array(lines[i])[j] != "#" {
            availableCells.append(Cell(id: availableCellsCount, pos: (x:j, y:i-1), type: String(Array(lines[i])[j]) ))
            availableCellsCount += 1
        }
    }
}
availableCellsCount = devCount + pmCount

// Checking neighbors
func getNeighbors(c: Cell) -> [Int]{
    var n:[Int] = []
    var ind = -1
    //TOP
    if c.pos.y>0 {
        ind = getCellId(x: c.pos.x, y: c.pos.y-1)
        if ind > -1 && !availableCells[ind].neighbors.contains(c.id){ //!contains to avoid duplicates
            n.append(ind)
        }
    }
    //BOTTOM
    if c.pos.y<size.height-1 {
        ind = getCellId(x: c.pos.x, y: c.pos.y+1)
        if ind > -1 && !availableCells[ind].neighbors.contains(c.id){ //!contains to avoid duplicates
            n.append(ind)
        }
    }
    //LEFT
    if c.pos.x>0 {
        ind = getCellId(x: c.pos.x-1, y: c.pos.y)
        if ind > -1 && !availableCells[ind].neighbors.contains(c.id){ //!contains to avoid duplicates
            n.append(ind)
        }
    }
    //RIGHT
    if c.pos.x<size.width-1 {
        ind = getCellId(x: c.pos.x+1, y: c.pos.y)
        if ind > -1 && !availableCells[ind].neighbors.contains(c.id){ //!contains to avoid duplicates
            n.append(ind)
        }
    }
    return n
}

func getCellId(x:Int, y:Int) -> Int{
    var ind = -1
    for i in 0..<availableCellsCount{
        if availableCells[i].pos.x == x && availableCells[i].pos.y == y{
            ind = availableCells[i].id
        }
    }
    return ind
}

for i in 0..<availableCells.count{
    availableCells[i].neighbors.append(contentsOf: getNeighbors(c: availableCells[i]))
}
//after getting neighbors, sort the array by type
availableCells = availableCells.sorted(by: { $0.type > $1.type })


// List of developers
var cursor:Int = size.height+1
let numDevs:Int =  Int(lines[cursor])!
cursor += 1

var devs:[Developer] = []
var count:Int = 0
for i in cursor..<(cursor+numDevs){
    let info = lines[i].split(separator: " ").map(String.init)
    var skills:[String] = []
    for j in 3..<info.count{
        skills.append(info[j])
    }
    devs.append(Developer(id: count, company: info[0], bonus: Int(info[1])!, skillsNum: Int(info[2])!, skills: skills))
    cursor+=1
    count+=1
}

// List of project managers
let numPMs:Int =  Int(lines[cursor])!
cursor+=1

var pms:[PM] = []
count = 0
for i in cursor..<(cursor+numPMs){
    let info = lines[i].split(separator: " ").map(String.init)
    pms.append(PM(id:count,company: info[0], bonus: Int(info[1])!))
    cursor+=1
    count+=1
}

// Printing data
print("Available cells: \(availableCellsCount)")
for c in availableCells{
    print(c)
}
print("------------------")

print("Developers: \(numDevs)")
for d in devs{
    print(d)
}
print("------------------")

print("Project Managers: \(numPMs)")
for p in pms{
    print(p)
}
print("------------------")


// GENETIC ALGORITHM
class Gene: CustomStringConvertible{
    var cell:Cell
    var person:Person
    
    init(cell:Cell, person:Person) {
        self.cell = cell
        self.person = person
    }
}

class Chromossome: CustomStringConvertible{
    var genes:[Gene]
    var fitness:Int = 0
    
    init() {
        genes = []
        
        var selectedDevs:[Int] = []
        for i in 0..<devCount{
            var randD:Int = -1
            repeat{
                randD = Int.random(in: 0..<devs.count)
            } while (selectedDevs.contains(randD))
            selectedDevs.append(randD)
            
            genes.append(Gene(cell: availableCells[i], person: devs[randD]))
        }
        var selectedPMs:[Int] = []
        for i in 0..<pmCount{
            var randP:Int = -1
            repeat{
                randP = Int.random(in: 0..<pms.count)
            } while (selectedPMs.contains(randP))
            
            selectedPMs.append(randP)
            genes.append(Gene(cell: availableCells[i + devCount], person: pms[randP]))
        }
        calcFitness()
    }
    
    func calcFitness(){
        for g1 in genes{
            for g2_ind in g1.cell.neighbors{
                var wp:Int = 0
                let g2:Gene = genes[getGeneIndex(by: g2_ind)]
                if type(of: g1.person) == Developer.self && type(of: g2.person) == Developer.self{
                    //Both developers
                    let sharedSkills:Int = (g1.person as! Developer).skills.filter((g2.person as! Developer).skills.contains).count
                    let distinctSkills = (g1.person as! Developer).skills.count + (g2.person as! Developer).skills.count - 2 * sharedSkills
                    wp = sharedSkills * distinctSkills
                }
                let bp:Int = (g1.person.company == g2.person.company) ? g1.person.bonus * g2.person.bonus : 0
                let tp = wp + bp
                fitness += tp
            }
        }
    }
    
    func getGeneIndex(by cellId:Int) -> Int{
        var ind = -1
        for i in 0..<genes.count{
            if genes[i].cell.id == cellId{
                return i
            }
        }
        return ind
    }
}

func crossover(c1:Chromossome, c2:Chromossome) -> (cn1:Chromossome, cn2:Chromossome){
    let cn1:Chromossome = Chromossome()
    let cn2:Chromossome = Chromossome()
    
    for i in 0..<devCount{
        cn1.genes[i] = c1.genes[i]
        cn2.genes[i] = c2.genes[i]
    }
    for i in devCount..<availableCellsCount{
        cn1.genes[i] = c2.genes[i]
        cn2.genes[i] = c1.genes[i]
    }
    cn1.calcFitness()
    cn2.calcFitness()
    return (cn1:cn1, cn2:cn2)
}

func mutate(c:Chromossome) -> Chromossome{
    let n:Chromossome = Chromossome()
    var devIds:[Int] = []
    var pmIds:[Int] = []
    
    for i in 0..<devCount{
        devIds.append(n.genes[i].person.id)
    }
    for i in devCount..<n.genes.count{
        pmIds.append(n.genes[i].person.id)
    }
    let pos:Int = Int.random(in: 0..<n.genes.count)
    
    if pos < devCount{
        //mutate a developer
        var id = -1
        repeat{
            id = Int.random(in: 0..<devs.count)
        } while (devIds.contains(id))
        n.genes[pos].person = devs[id]
    } else {
        //mutate a pm
        var id = -1
        repeat{
            id = Int.random(in: 0..<pms.count)
        } while (pmIds.contains(id))
        n.genes[pos].person = pms[id]
    }

    n.calcFitness()
    return n
}

let POP_SIZE = 500
let NUM_GEN = 50
let MUT_PROB:Double = 0.1
let ELI_NUM = 100

func genPopulation(size:Int) -> [Chromossome]{
    var pop:[Chromossome] = []
    for _ in 0..<size{
        pop.append(Chromossome())
    }
    return pop
}

var pop:[Chromossome] = genPopulation(size: POP_SIZE)
for i in 0..<NUM_GEN{
//    pop = genPopulation(size: POP_SIZE)
    // Init population
    if i != 0 {
        var elitism:[Chromossome] = []
        for j in 0..<ELI_NUM{
            elitism.append(pop[j])
        }
        let tempPop = genPopulation(size: POP_SIZE - ELI_NUM)
        pop = []
        pop.append(contentsOf: elitism)
        pop.append(contentsOf: tempPop)
    }
    
    // Crossover
    for j in stride(from: 0, through: POP_SIZE-2, by: 2){
        let temp = crossover(c1: pop[j], c2: pop[j + 1])
        var chromossomes:[Chromossome] = [pop[j], pop[j + 1], temp.cn1, temp.cn2]
        chromossomes = chromossomes.sorted(by: { $0.fitness > $1.fitness })
        pop[j] = chromossomes[0]
        pop[j+1] = chromossomes[1]
    }

    //Mutation
    for i in 0..<pop.count{
        let prob:Double = Double.random(in: 0..<1)
        if prob < MUT_PROB{
            pop[i] = mutate(c: pop[i])
        }
    }
    
    pop = pop.sorted(by: { $0.fitness > $1.fitness })
    print("BEST FITNESS: \(pop[0].fitness)")
}

func getDevPos(in chromossome:Chromossome, id:Int) -> (x:Int, y:Int){
    var pos:(x:Int, y:Int) = (x:-1, y:-1)
    for c in chromossome.genes{
        if type(of: c.person) == Developer.self && c.person.id == id {
            pos = c.cell.pos
        }
    }
    return pos
}

func getPMPos(in chromossome:Chromossome, id:Int) -> (x:Int, y:Int){
    var pos:(x:Int, y:Int) = (x:-1, y:-1)
    for c in chromossome.genes{
        if type(of: c.person) == PM.self && c.person.id == id {
            pos = c.cell.pos
        }
    }
    return pos
}

for g in pop[0].genes{
    print("\(g.cell.pos) \(g.person)")
}

// SAVING FILE
let sw = StreamWriter(path: (NSString(string:"~/Desktop/\(files[activeFile])_output.txt").expandingTildeInPath ))
for d in devs{
    let p = getDevPos(in: pop[0], id: d.id)
    if p.x == -1 {
        sw?.writeLine(data: "X")
    } else {
        sw?.writeLine(data: "\(p.x) \(p.y)")
    }
}
for d in pms{
    let p = getPMPos(in: pop[0], id: d.id)
    if p.x == -1 {
        sw?.writeLine(data: "X")
    } else {
        sw?.writeLine(data: "\(p.x) \(p.y)")
    }
}



// SAVING FILE
//let sw = StreamWriter(path: (NSString(string:"~/Desktop/a_solar_output.txt").expandingTildeInPath ))
//sw?.write(data: "Hello, World!")

