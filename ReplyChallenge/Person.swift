//
//  Person.swift
//  ReplyChallenge
//
//  Created by Pedro Giuliano Farina on 12/03/20.
//  Copyright © 2020 Pedro Cacique. All rights reserved.
//

import Foundation

public struct Person: Hashable {
    let company: String
    let bonusPotencial: Int
    let skills: Set<String>
    let role: Role

    func getScoreWith(_ person: Person) -> Int {
        var score = 0
        if role == .dev && person.role == .dev {
            let skillsFactor = skills.intersection(person.skills).count * (skills.union(person.skills).count - skills.intersection(person.skills).count)
            score += skillsFactor
        }
        if person.company == company {
            score += bonusPotencial
        }

        return score
    }
}

enum Role: Int {
    case dev = 1
    case manager = 2
}
