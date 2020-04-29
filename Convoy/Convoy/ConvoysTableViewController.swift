//
//  ConvoysTableViewController.swift
//  Convoy
//
//  Created by Jack Adams on 26/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit

class ConvoysTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        tableView.allowsSelection = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddClick(sender:)))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .white
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

    
    @objc func onAddClick(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "NewConvoy", bundle: nil)
        let VC = storyboard.instantiateInitialViewController() as! NewConvoyViewController
        
        navigationController?.pushViewController(VC, animated: true)
        
    }


}
