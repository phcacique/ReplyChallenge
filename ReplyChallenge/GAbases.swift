////
////  GAbases.swift
////  ReplyChallenge
////
////  Created by Joaquim Pessoa Filho on 12/03/20.
////  Copyright © 2020 Pedro Cacique. All rights reserved.
////

import Foundation

enum Position {
    case Unavailable
    case Developer(i:Int)
    case PM(i:Int)
}

struct Individual {
    let developers:[Developer]
    let pms:[PM]
    let fitness:Int
}

class Population {
    var individual:[Individual] = []
}

class GA {
    var room:[[Position]]
    let rows = 3
    let colls = 5
    var bestFitness = 0
    let population: Population = Population()
    let devs: [Developer]
    let pms: [PM]
    var numberOfDevPositions:Int = 0
    var numberOfPMPositions:Int = 0
    
    init(devs: [Developer], pms: [PM], pmAvailable:Int, devAvailable: Int) {
        room = [[.Unavailable, .Unavailable, .Unavailable, .Unavailable, .Unavailable],
                [.Unavailable, .Developer(i: 0), .Unavailable, .Unavailable, .Developer(i: 1)],
                [.Unavailable, .PM(i: 0), .PM(i: 1), .Developer(i: 2), .Developer(i: 3)]
        ]
        
        self.devs = devs
        self.pms = pms
        
        self.numberOfPMPositions = pmAvailable
        self.numberOfDevPositions = devAvailable
        
        self.createInitialPopulation()
    }
    
    private func createInitialPopulation() {
        for _ in 0...100 {
            var iDevs:[Developer] = randDevs()
            var iPMs:[PM] = randPMs()
            
            let fitness = self.fitnessCalculate(devs: iDevs, pms: iPMs)
            let individual = Individual(developers: iDevs, pms: iPMs, fitness: fitness)
            self.population.individual.append(individual)
        }
    }
    
    private func fitnessCalculate(devs:[Developer], pms:[PM]) -> Int {
        return -1
    }
    
    private func randDevs() -> [Developer] {
        let shuffledDevs =  self.devs.shuffled()
        return subArray(array: shuffledDevs, range: NSRange(location: 0, length: self.numberOfDevPositions))
    }
    
    private func randPMs() -> [PM] {
        let shuffledPMs =  self.pms.shuffled()
        return subArray(array: shuffledPMs, range: NSRange(location: 0, length: self.numberOfPMPositions))
    }
    
    func subArray<T>(array: [T], range: NSRange) -> [T] {
      if range.location > array.count {
        return []
      }
      return Array(array[range.location..<min(range.length, array.count)])
    }
}

