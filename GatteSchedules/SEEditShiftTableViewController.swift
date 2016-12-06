//
//  SEEditShiftTableViewController.swift
//  GatteSchedules
//
//  Created by Colby Gatte on 12/2/16.
//  Copyright © 2016 colbyg. All rights reserved.
//

import UIKit

class SEEditShiftTableViewController: UITableViewController {
    var schedule: GSSchedule!
    var day: GSDay!
    var shift: GSShift!
    
    var positionIds: [String]!
    var positions: [String: String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        positions = App.teamSettings.positions
        positionIds = Array(positions.keys)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return positionIds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = positions[positionIds[indexPath.row]]!
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SEEditPosition" {
            let row = (tableView.indexPathForSelectedRow?.row)!
            let seEditPositionViewController = segue.destination as! SEEditPositionViewController
            
            seEditPositionViewController.position = shift.get(position: positionIds[row])
            seEditPositionViewController.schedule = schedule
            seEditPositionViewController.day = day
        }
    }
}
