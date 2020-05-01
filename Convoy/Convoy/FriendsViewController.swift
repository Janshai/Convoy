//
//  FriendsViewController.swift
//  Convoy
//
//  Created by Jack Adams on 23/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    @IBOutlet weak var friendSearchBar: UISearchBar!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    
    var friends: [UserViewModel] = [] {
        didSet {
            if oldValue != friends {
                friendsTableView.reloadData()
            }
        }
    }
    
    var filteredFriends: [UserViewModel] = []
    
    var isFiltering: Bool {
        return !(friendSearchBar.text?.isEmpty ?? true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendSearchBar.delegate = self
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.allowsSelection = false
        // Do any additional setup after loading the view.
    }
    
    func filterFriends(for searchText: String) {
        UserViewModel.searchFriends(for: searchText) { [weak self] userVMs in
            
            if let strongSelf = self {
                strongSelf.filteredFriends = userVMs
                strongSelf.friendsTableView.reloadData()
            }
            
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

extension FriendsViewController: UISearchBarDelegate {
    
    
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
        performSegue(withIdentifier: "addFriends", sender: self)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFriends(for: searchText)
    }
}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        UserViewModel.getFriends() { [weak self] VMs in
            if let strongSelf = self {
                strongSelf.friends = VMs
            }
            
        }
        
        return isFiltering ? self.filteredFriends.count : self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "friend") {
            cell.textLabel?.text = isFiltering ? filteredFriends[indexPath.row].name : friends[indexPath.row].name
                
                return cell
        } else {
            return UITableViewCell()
        }
        }
        
    
    
}
