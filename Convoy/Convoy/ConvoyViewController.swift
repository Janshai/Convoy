//
//  ConvoyViewController.swift
//  Convoy
//
//  Created by Jack Adams on 27/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit
import Eureka

class ConvoyViewController: ConvoyFriendInviteViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .white
        view.backgroundColor = .white
        navigationItem.title = "Convoy Name"
        
        //set invited friends
        
        form +++ Section("Destination")
            <<< LabelRow() { row in
                row.title = "Destination Name"
        }
            +++ inviteFriendsSection()
            +++ Section("Your Start Location")
            <<< LabelRow() { row in
                row.title = "Start Location"
                
        }
            +++ ButtonRow() { row in
                row.title = "Commence Journey"
            }.onCellSelection() { cell, row in
                return
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
