//
//  ConvoyViewModel.swift
//  Convoy
//
//  Created by Jack Adams on 27/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation

class ConvoyViewModel {
    
    var convoy: Convoy
    var name: String
    var destinationName: String
    var startName: String {
        get {
            if let user = UserModel.shared.signedInUser {
                let member = convoy.members?.first() {
                    $0.userUID == user.userUID
                }
                return member?.startLocationPlaceName ?? ""
            } else {
                return ""
            }
            
        }
    }
    
    var members: [MemberViewModel]
    
    init(convoy: Convoy) {
        name = convoy.name
        destinationName = convoy.destinationPlaceName
        self.convoy = convoy
        self.members = []
        if let convoyMembers = convoy.members {
            
            for m in convoyMembers {
                self.members.append(MemberViewModel(member: m))
            }
        }
    }
    
    
    
    func acceptInvite(withStartLocation location: [String: Any]) {
        ConvoyModel.shared.acceptInvite(to: self.convoy, withStartLocation: location)
    }
    
    func declineInvite() {
        ConvoyModel.shared.declineInvite(to: self.convoy)
    }
    
    
    
    static func createConvoy(with data: [String:Any], onCompletion completion: @escaping () -> Void) {
        ConvoyModel.shared.createConvoy(from: data) { error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                completion()
            }
        }
    }
    static func getAllConvoys(onComplete completion: @escaping ([ConvoyViewModel]) -> Void) {
        
        ConvoyModel.shared.getConvoys() {result in
                var vms: [ConvoyViewModel] = []
                switch result {
                case .success(let convoys):
                    for convoy in convoys {
                        vms.append(ConvoyViewModel(convoy: convoy))
                    }
                    completion(vms)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion([])
                }
            }
        
    }
    
    static func getConvoyInvites(onCompletion completion: @escaping ([ConvoyViewModel]) -> Void) {
        ConvoyModel.shared.getConvoyInvites() { result in
            var vms: [ConvoyViewModel] = []
            switch result {
            case .success(let convoys):
                for convoy in convoys {
                    vms.append(ConvoyViewModel(convoy: convoy))
                }
                completion(vms)
            case .failure(let error):
                print(error.localizedDescription)
                completion([])
            }
        }
    }
}

class MemberViewModel {
    var name: String
    var start: [String:Double]
    var startName: String
    var status: String
    
    var member: ConvoyMember
    
    init(member: ConvoyMember) {
        self.start = member.start
        self.startName = member.startLocationPlaceName
        self.name = ""
        self.status = ""
        self.member = member
        switch member.status {
        case "not started": self.status = "Not Started"
        case "in progress": self.status = "In Progress"
        case "invited": self.status = "Invited"
        default: self.status = ""
        }
        UserModel.shared.getUser(withID: member.userUID) { result in
            switch result {
            case .success(let user):
                self.name = user.displayName
            case .failure(_):
                self.name = ""
            }
        }
    }
}
