//
//  AddFriendsViewController.swift
//  Convoy
//
//  Created by Jack Adams on 23/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController {
    @IBOutlet weak var addFriendsTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func clickClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var isFiltering: Bool {
        return !(searchBar.text?.isEmpty ?? true)
    }
    
    var friendRequests: [UserViewModel] = []
    
    var filteredUsers: [UserViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFriendsTableView.delegate = self
        addFriendsTableView.dataSource = self
        searchBar.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .gray
        addFriendsTableView.backgroundView = indicator
        indicator.startAnimating()
        UserViewModel.getFriendRequests() { [weak self] VMs in
            
            if let strongSelf = self {
                strongSelf.friendRequests = VMs
                indicator.stopAnimating()
                strongSelf.addFriendsTableView.backgroundView = nil
                strongSelf.addFriendsTableView.reloadData()
            }
        }
    }
    
    func filterUsers(for searchText: String) {
        UserViewModel.searchAllUsers(for: searchText) { [weak self] userVMs in
            
            if let strongSelf = self {
                strongSelf.filteredUsers = userVMs
                strongSelf.addFriendsTableView.reloadData()
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

extension AddFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = isFiltering ? filteredUsers.count : friendRequests.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFiltering {
            let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
            cell.textLabel?.text = filteredUsers[indexPath.row].name
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequest", for: indexPath) as? FriendRequestTableViewCell {
                cell.user = friendRequests[indexPath.row]
                cell.tableview = tableView
                return cell
            } else {
                return UITableViewCell()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering {
            let user = filteredUsers[indexPath.row]
            let message = "Do you want to send a friend request to " + user.name + "?"
            let alertController = UIAlertController(title: "Friend Request", message: message, preferredStyle: .alert)

            // Create the actions
            let sendAction = UIAlertAction(title: "Send", style: UIAlertAction.Style.default) {
                UIAlertAction in
                user.sendFriendRequest()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                return
            }

            // Add the actions
            alertController.addAction(sendAction)
            alertController.addAction(cancelAction)

            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        
        }
    }
    
    
}

extension AddFriendsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterUsers(for: searchText)
    }
    
}
