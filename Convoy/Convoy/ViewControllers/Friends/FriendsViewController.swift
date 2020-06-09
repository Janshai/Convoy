//
//  FriendsViewController.swift
//  Convoy
//
//  Created by Jack Adams on 23/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    var friendSearchBar = UISearchBar()
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    
    var friends: [UserViewModel] = []
    
    var filteredFriends: [UserViewModel] = []
    
    var isFiltering: Bool {
        return !(friendSearchBar.text?.isEmpty ?? true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendSearchBar.sizeToFit()
        friendSearchBar.delegate = self
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.allowsSelection = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddClick))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(loadUserProfile))
        self.navigationItem.rightBarButtonItem?.tintColor = nil
        self.navigationItem.titleView = friendSearchBar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let auth = FirebaseAuthService()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            if auth.currentUser == nil {
                self.performSegue(withIdentifier: "logout", sender: nil)
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .gray
        friendsTableView.backgroundView = indicator
        indicator.startAnimating()
        UserViewModel.getFriends() { [weak self] VMs in
            if let strongSelf = self {
                strongSelf.friends = VMs
                indicator.stopAnimating()
                strongSelf.friendsTableView.backgroundView = nil
                strongSelf.friendsTableView.reloadData()
            }
            
        }
    }
    
    func filterFriends(for searchText: String) {
        UserViewModel.searchFriends(for: searchText) { [weak self] userVMs in
            
            if let strongSelf = self {
                strongSelf.filteredFriends = userVMs
                strongSelf.friendsTableView.reloadData()
            }
            
        }
        
        
    }
    
    @objc func onAddClick() {
        performSegue(withIdentifier: "addFriends", sender: nil)
    }
    
    @objc func loadUserProfile() {
        present(ProfileViewController(), animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logout" {
            navigationController?.popToRootViewController(animated: false)
            tabBarController?.dismiss(animated: false, completion: nil)
        }
    }

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
