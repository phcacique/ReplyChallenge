//
//  Office.swift
//  ReplyChallenge
//
//  Created by Pedro Giuliano Farina on 12/03/20.
//  Copyright © 2020 Pedro Cacique. All rights reserved.
//

import Foundation

class Office {
    let width: Int
    let height: Int
    public private(set) lazy var chairs: [Chair] = [Chair].init(repeating: .unavailable, count: width * height)
    public private(set) lazy var persons: Dictionary<Int, Person> =  [:]

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    func setLine(_ i: Int, to value: String) {
        var newChairs: [Chair] = []
        for c in value {
            let newChair: Chair
            switch c {
            case "_":
                newChair = .dev
            case "M":
                newChair = .manager
            default:
                newChair = .unavailable
            }
            newChairs.append(newChair)
        }
        let from = i * width
        let to = ((i + 1) * width) - 1

        chairs.replaceSubrange(from ... to, with: newChairs)
    }

    func getChair(line: Int, column: Int) -> Chair {
        let startingPoint = line * width
        return chairs[startingPoint + column]
    }

    func addPerson(_ person: Person, at point: (Int, Int)) -> Bool {
        let index = point.0 * width + point.1
        if chairs[index].rawValue == person.role.rawValue {
            persons[index] = person
            return true
        }
        return false
    }

    func getScoreFor(line: Int, column: Int) -> Int {
        let index = line * width + column
        var score = 0
        if let person = persons[index] {
            let indexes = [index + 1, index - 1, index + width, index - width]
            for colleagueIndex in indexes {
                if let colleague = persons[colleagueIndex] {
                    score += person.getScoreWith(colleague)
                }
            }
        }
        return score
    }
}

enum Chair: Int {
    case unavailable = 0
    case dev = 1
    case manager = 2
}
