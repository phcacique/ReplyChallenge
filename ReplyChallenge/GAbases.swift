//
//  GAbases.swift
//  ReplyChallenge
//
//  Created by Joaquim Pessoa Filho on 12/03/20.
//  Copyright © 2020 Pedro Cacique. All rights reserved.
//

import Foundation

enum Position {
    case Unavailable
    case Developer(i:Int)
    case PM(i:Int)
}

struct Developer {
    let company:String
    let bonus: Int
    let skills: [String]
    
    init(description: String) {
        let desc = description.split(separator: " ")
        
    }
}

struct PM {
}

struct Individual {
    let developers:[Developer]
    let pms:[PM]
    let fitness = 0
}

class Population {
    var individual:[Individual]
}

class GA {
    var room:[[Position]]
    let rows = 3
    let colls = 5
    var bestFitness = 0
    let population: Population
    var numberOfDevs = 0
    var numberOfPMs = 0
    
    init() {
        room = [[.Unavailable, .Unavailable, .Unavailable, .Unavailable, .Unavailable],
                [.Unavailable, .Developer(i: 0), .Unavailable, .Unavailable, .Developer(i: 1)],
                [.Unavailable, .PM(i: 0), .PM(i: 1), .Developer(i: 2), .Developer(i: 3)]
        ]
        self.numberOfPMs = 2
        self.numberOfDevs = 4
    }
    
    private create initialPopulation() {
        for i in 0...100 {
            
        }
    }
    
    
    
    
}

