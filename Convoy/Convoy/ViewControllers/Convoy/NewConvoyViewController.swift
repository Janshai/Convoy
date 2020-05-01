//
//  NewConvoyViewController.swift
//  Convoy
//
//  Created by Jack Adams on 28/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit

class NewConvoyViewController: UIViewController {
    @IBOutlet weak var invitesButton: UIButton!
    @IBOutlet weak var newButton: UIButton!
    
    @IBAction func clickInvites(_ sender: UIButton) {
        navigationController?.pushViewController(ConvoyInvitesViewController(), animated: true)
    }
    @IBAction func clickNew(_ sender: UIButton) {
        navigationController?.pushViewController(AddConvoyViewController(), animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButton(button: newButton)
        setupButton(button: invitesButton)
        navigationItem.title = "New Convoy"
    }
    
    func setupButton(button: UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = button.tintColor.cgColor
        
        button.layer.cornerRadius = 2.0
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
