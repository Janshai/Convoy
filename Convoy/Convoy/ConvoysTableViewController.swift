//
//  ConvoysTableViewController.swift
//  Convoy
//
//  Created by Jack Adams on 26/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit

class ConvoysTableViewController: UITableViewController {
    
    var convoys: [ConvoyViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddClick(sender:)))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .white
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ConvoyViewModel.getAllConvoys() { [weak self] VMs in
            if let strongSelf = self {
                strongSelf.convoys = VMs
                UIView.transition(with: strongSelf.tableView,
                duration: 0.35,
                options: .transitionCrossDissolve,
                animations: { strongSelf.tableView.reloadData() })
            }
        }
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        return self.convoys.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "convoy", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.convoys[indexPath.row].name
        cell.selectionStyle = .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ConvoyViewController()
        vc.convoy = convoys[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onAddClick(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "NewConvoy", bundle: nil)
        let VC = storyboard.instantiateInitialViewController() as! NewConvoyViewController
        
        navigationController?.pushViewController(VC, animated: true)
        
    }


}
