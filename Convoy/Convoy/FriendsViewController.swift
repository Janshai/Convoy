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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendSearchBar.delegate = self
        
        // Do any additional setup after loading the view.
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
}
