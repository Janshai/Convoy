//
//  ConvoyFriendInviteViewController.swift
//  Convoy
//
//  Created by Jack Adams on 27/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit
import Eureka

class ConvoyFriendInviteViewController: FormViewController {
    
    var friends: [UserViewModel]?
    var invitedFriends: [UserViewModel]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func inviteFriendsSection(withDeletion deletion: Bool) -> MultivaluedSection {
        let multivaluedOptions: MultivaluedOptions = deletion ? [.Insert, .Delete] : [.Insert]
        return MultivaluedSection(multivaluedOptions: multivaluedOptions, header: "Friends to Invite", {
            $0.tag = "friends"
            $0.addButtonProvider = { section in
                return ButtonRow(){
                    $0.title = "Invite Friend"
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return PushRow<String>() {
                    $0.title = "Select Friend to Invite"
                    $0.optionsProvider = .lazy() { [weak self] form, completion in
                        form.tableView.backgroundColor = .white
                        if let strongSelf = self {
                            if strongSelf.friends == nil {
                                let activityView = UIActivityIndicatorView(style: .gray)
                                form.tableView.backgroundView = activityView
                                activityView.startAnimating()
                                UserViewModel.getFriends() { [weak self] VMs in
                                    if let strongSelf2 = self {
                                        strongSelf2.friends = VMs
                                        form.tableView.backgroundView = nil
                                        completion(strongSelf2.getFriendOptionsList())
                                        
                                    } else {
                                        form.tableView.backgroundView = nil
                                        completion([])
                                    }
                                    
                                }
                            } else {
                                completion(strongSelf.getFriendOptionsList())
                            }
                        } else {
                            completion([])
                        }
                        
                    }
                }
            }
            guard let invited = invitedFriends else {
                return
            }
            for friend in invited {
                $0 <<< LabelRow() { row in
                    row.title = friend.name
                }
            }
            
        })
        // Do any additional setup after loading the view.
    }
    
    func getFriendOptionsList() -> [String] {
        var options: [String] = []
        guard let friends = self.friends else {
            return []
        }
        for f in friends {
            options.append(f.name)
        }
        return options
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
