//
//  GSUsers.swift
//  GatteSchedules
//
//  Created by Colby Gatte on 11/29/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

import Foundation
import Firebase

class GSUser: NSObject {
    var uid: String!
    
    var teamid: String!
    var name: String!
    var email: String!
    var positions: [String]!
    var permissions: String!
    
    init(snapshot: FIRDataSnapshot, uid: String) {
        let values = snapshot.value as! [String: Any]
        self.uid = uid
        name = values["name"] as! String
        teamid = values["teamid"] as! String
        permissions = values["permissions"] as! String
        email = values["email"] as! String
        
        positions = []
        let positionsValues = values["positions"] as? [String]
        if positionsValues != nil {
            for position in positionsValues! {
                positions.append(position)
            }
        }
    }
    
    init(uid: String, email: String, name: String, teamid: String, permissions: String, positions: [String]) {
        self.uid = uid
        self.email = email
        self.name = name
        self.teamid = teamid
        self.permissions = permissions
        self.positions = positions
    }
    
    func toFirebaseObject() -> Any {
        var userObject: [String: Any] = [:]
        
        userObject["name"] = name
        userObject["permissions"] = permissions
        userObject["teamid"] = teamid
        userObject["positions"] = positions
        userObject["email"] = email
        
        return userObject
    }
    
    func canDo(position: String) -> Bool {
        return positions.contains(position)
    }
}
