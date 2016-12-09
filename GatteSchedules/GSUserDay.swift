//
//  GSUserDay.swift
//  GatteSchedules
//
//  Created by Colby Gatte on 12/6/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

import UIKit

class GSUserDay: NSObject {
    var user: GSUser!
    var date: Date!
    var notes: String!
    var published: Bool!
    var shifts: [GSUserShift]!
    
    var isOff: Bool {
        return shifts.count == 0
    }
    
    init(date: Date, user: GSUser) {
        self.date = date
        self.user = user
        self.published = false
        shifts = []
    }
    
    init(from day: GSDay, user: GSUser) {
        super.init()
        self.user = user
        self.date = day.date
        shifts = []
        self.published = day.published
        
        if published == true {
            addData(day: day)
        }
    }
    
    func addData(day: GSDay) {
        shifts = []
        
        self.published = day.published
        for shift in day.shifts.values {
            for position in shift.positions.values {
                if position.workers.contains(user) {
                    let shift = GSUserShift(shiftid: shift.shiftid, positionid: position.positionid)
                    shifts.append(shift)
                }
            }
        }
    }
    
    func getWorkingPositions() -> [GSUserPosition] {
        var workingPositions: [GSUserPosition] = []
        
        for shift in shifts {
            workingPositions.append(shift.position)
        }
        
        return workingPositions
    }
}
