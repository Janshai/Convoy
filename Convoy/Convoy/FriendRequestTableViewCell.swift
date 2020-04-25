//
//  FriendRequestTableViewCell.swift
//  Convoy
//
//  Created by Jack Adams on 24/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {
    
    var user: UserViewModel? {
        didSet {
            nameLabel.text = user?.name
        }
    }
    
    weak var tableview: UITableView?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBAction func tapAccept(_ sender: UIButton) {
        
        user?.acceptFriendRequest()
        tableview?.reloadData()
    }
    
    @IBAction func tapReject(_ sender: UIButton) {
        user?.rejectFriendRequest()
        tableview?.reloadData()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
