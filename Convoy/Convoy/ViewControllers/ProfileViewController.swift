//
//  ProfileViewController.swift
//  Convoy
//
//  Created by Jack Adams on 08/06/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit
import Eureka

class ProfileViewController: FormViewController {
    let auth = FirebaseAuthService()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.form +++ Section("Profile")
            <<< LabelRow() { row in
                row.title = auth.currentUser?.displayName
            }
            <<< ButtonRow() { row in
                row.title = "Log Out"
                row.onCellSelection() { [weak self] cell, row in
                    self?.auth.logOut()
                    self?.dismiss(animated: true, completion: nil)
                    
                }
        }
        
        self.navigationItem.title = "Profile"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
    
        // Do any additional setup after loading the view.
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
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
