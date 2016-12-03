//
//  DB.swift
//  GatteSchedules
//
//  Created by Colby Gatte on 11/28/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

import Foundation
import Firebase

class DB {
    static var teamid: String!
    static var teamRef: FIRDatabaseReference!
    static var usersRef: FIRDatabaseReference!
    static var pendingUsersRef: FIRDatabaseReference!
    static var ref: FIRDatabaseReference!
    
    private static var authListenerHandle: FIRAuthStateDidChangeListenerHandle! // @@@@ should probably be optional
    private static var authListenerBlock: FIRAuthStateDidChangeListenerBlock!
    static var authListenerIsListening: Bool = false
    
    // Authentication, login, and settings
    static func setAuthListener(listener: @escaping FIRAuthStateDidChangeListenerBlock) {
        DB.authListenerBlock = listener
    }
    
    static func stopAuthListener() {
        if DB.authListenerIsListening {
            FIRAuth.auth()?.removeStateDidChangeListener(DB.authListenerHandle)
            DB.authListenerIsListening = false
        }
    }
    
    static func startAuthListener() {
        if !DB.authListenerIsListening {
            DB.authListenerHandle = FIRAuth.auth()?.addStateDidChangeListener(DB.authListenerBlock)
            DB.authListenerIsListening = true
        }
    }
    
    
    static func signIn(username: String, password: String, completion: @escaping FirebaseAuth.FIRAuthResultCallback) {
        FIRAuth.auth()?.signIn(withEmail: username, password: password, completion: completion)
    }
    
    static func signOut(completion: (()->())? = nil) {
        try! FIRAuth.auth()?.signOut() // @@@@ handle the throw better
        
        if completion != nil {
            completion!()
        }
    }
    
    static func getSettings(completion: @escaping (FIRDataSnapshot)->()) {
        let ref = DB.teamRef.child("settings")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 0 {
                assert(true, "snapshot childrenCount == 0 for settings")
            } else {
                completion(snapshot)
            }
        })
    }
    
    static func save(settings: GSSettings) {
        DB.teamRef.child("settings").setValue(settings.toFirebaseObject())
    }
    
    // Schedules
    static func getSchedules(completion: @escaping (FIRDataSnapshot)->()) {
        DB.teamRef.child("schedules").observeSingleEvent(of: .value, with: { schedulesSnapshot in
            completion(schedulesSnapshot)
        })
    }
    
    static func getSchedule(schedule: String, completion: @escaping (FIRDataSnapshot)->()) {
        let ref = DB.teamRef.child("schedules").child(schedule)
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 0 {
                assert(true, "snapshot.childrenCount == 0")
            } else {
                completion(snapshot)
            }
        })
    }
    
    static func createSchedule(date: Date) -> FIRDatabaseReference {
        let dateString = App.formatter.string(from: date)
        let ref = DB.teamRef.child("schedules").child(dateString)
        return ref
    }
    
    static func save(schedule: GSSchedule) {
        schedule.ref.setValue(schedule.toFirebaseObject())
    }
    
    // Users
    static func createLogin(email: String, password: String, completion: FIRAuthResultCallback?) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { user, error in
            completion?(user, error)
        }
    }
    
    static func save(user: GSUser) {
        let userRef = DB.usersRef.child(user.uid)
        userRef.setValue(user.toFirebaseObject())
    }
    
    static func getUsers(completion: @escaping (FIRDataSnapshot)->()) {
        DB.usersRef.queryOrdered(byChild: "teamid").queryEqual(toValue: DB.teamid).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot)
        })
    }
    
    static func getUserData(uid: String, completion: @escaping (FIRDataSnapshot)->()) {
        let userDataRef = DB.usersRef.child(uid)
        
        userDataRef.observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot)
        })
    }
    
    static func getPendingUsers(completion: @escaping (FIRDataSnapshot)->Void) {
        DB.pendingUsersRef.queryOrdered(byChild: "teamid").queryEqual(toValue: DB.teamid).observeSingleEvent(of: .value, with: { pendingUsersSnap in
            completion(pendingUsersSnap)
        })
    }
    
    static func createPendingUser(name: String, email: String, teamid: String) {
        let pendingUserRef = DB.pendingUsersRef.child(String.random(length: 5)) // @@@@ check to see if str exists
        
        pendingUserRef.setValue([
            "name": name,
            "email": email,
            "teamid": teamid
        ])
    }
    
    static func getPendingUser(code: String, completion: @escaping (FIRDataSnapshot)->Void) {
        DB.ref.child("pendingUsers").child(code).observeSingleEvent(of: .value, with: { pendingUserSnap in
            completion(pendingUserSnap)
        })
    }
    
    static func deletePendingUser(code: String) {
        DB.pendingUsersRef.child(code).setValue(nil)
    }
    
    // this logs in user automatically (firebase does when creating a user)
    static func createUser(email: String, password: String, completion: FIRAuthResultCallback?) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: completion)
    }
}
