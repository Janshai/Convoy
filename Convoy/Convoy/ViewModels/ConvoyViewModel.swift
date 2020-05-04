//
//  ConvoyViewModel.swift
//  Convoy
//
//  Created by Jack Adams on 27/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation
import CoreLocation

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
    
    func updateCurrentLocation(to location: CLLocation) {
        ConvoyModel.shared.updateCurrentLocation(to: location, for: self.convoy)
    }
    
    func updateRoute(to route: [CLLocation]) {
        ConvoyModel.shared.updateRoute(to: route, for: self.convoy)
    }
    
    func updateMembers(onCompletion completion: @escaping (Convoy) -> Void) {
        ConvoyModel.shared.updateMembers(for: self.convoy) { c in
            if let convoyMembers = c.members {
                self.members = []
                for m in convoyMembers {
                    self.members.append(MemberViewModel(member: m))
                }
            }
            self.convoy = c
            completion(c)
        }
    }
    
    
    func acceptInvite(withStartLocation location: [String: Any]) {
        ConvoyModel.shared.acceptInvite(to: self.convoy, withStartLocation: location)
    }
    
    func declineInvite() {
        ConvoyModel.shared.declineInvite(to: self.convoy)
    }
    
    func commence() {
        ConvoyModel.shared.commence(convoy: self.convoy)
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
    var start: CLLocation?
    var startName: String?
    var status: String
    var currentLocation: CLLocation?
    var route: [CLLocation]?
    
    var member: ConvoyMember
    
    init(member: ConvoyMember) {
        if let startLocation = member.start {
            self.start = CLLocation(latitude: startLocation["lat"]!, longitude: startLocation["long"]!)
        }
        
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
        if let location = member.currentLocation {
            self.currentLocation = CLLocation(latitude: location["lat"]!, longitude: location["long"]!)
        }
        
        if let decodableRoute = member.route {
            self.route = []
            for location in decodableRoute {
                self.route?.append(CLLocation(latitude: location["lat"]!, longitude: location["long"]!))
            }
        }
        
    }
}
