//
//  ConvoyModel.swift
//  Convoy
//
//  Created by Jack Adams on 28/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

class ConvoyModel{
    
    
    static var shared = ConvoyModel()
    let db = Firestore.firestore()
    let dataStore = FirebaseDataStore()
    
    func getConvoys(onCompletion completion: @escaping (Result<[Convoy], Error>) -> Void) {
        let group = DispatchGroup()
        var convoys: [Convoy] = []
        

        guard let user = UserModel.shared.signedInUser else {
            completion(.failure(NoUserSignedInError()))
            return
        }
        group.enter()
        let condition = DataStoreCondition(field: MemberFields.userUID , op: FirebaseOperator.isEqualTo, value: user.userUID)
        dataStore.getSubGroup(ofType: .members, withConditions: [condition]) { [weak self] result in
            
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let documents):
                for doc in documents {
                    if let status = doc.data()?["status"] as? String, status != "requested", status != "finished" {
                        let convoyID = doc.parentDocID
                        if let id = convoyID, let strongSelf = self {
                            strongSelf.dataStore.getDataStoreDocument(ofType: .convoy, withID: id) { result in
                                switch result {
                                case .failure(let err):
                                    completion(.failure(err))
                                case .success(let doc):
                                    let final: Result<Convoy, Error> = doc.getAsType(type: .convoy)
                                    switch final {
                                    case .failure(let e):
                                        completion(.failure(e))
                                    case .success(let c):
                                        convoys.append(c)
                                        group.leave()
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    
                }
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(.success(convoys))
        }
    }
    
    func acceptInvite(to convoy: Convoy, withStartLocation data: [String: Any]) {
        var mutatableData = data
        mutatableData["status"] = "not started"
        updateUserMembership(for: convoy, withData: mutatableData)
    }
    
    func declineInvite(to convoy: Convoy) {
        
        let data = [
            "status": "declined"
        ]
        
        updateUserMembership(for: convoy, withData: data)
    }
    
    func updateUserMembership(for convoy: Convoy, withData data: [String:Any]) {
        guard let user = UserModel.shared.signedInUser else {
            return
        }
        
        dataStore.getDataStoreDocument(ofType: .convoy, withID: convoy.convoyID!) { result in
            switch result {
            case .failure(let err):
                print(err.localizedDescription)
            case .success(let doc):
                let condition = DataStoreCondition(field: MemberFields.userUID, op: FirebaseOperator.isEqualTo, value: user.userUID)
                doc.getSubgroupDocument(ofType: .members, withConditions: [condition]) { memberResult in
                    switch memberResult {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let docs):
                        if let first = docs.first {
                            first.update(withData: data)
                        }
                    }
                }
            }
        }
    }
    
    func createConvoy(from data: [String:Any], onCompletion completion: @escaping (Error?) -> Void) {
        var newData: [String: Any]
        var memberData: [[String:Any]]
        (newData, memberData) = formatCreationData(in: data)
        
        let group = DispatchGroup()
        group.enter()
        let id = dataStore.addDocument(to: .convoy, newData: newData) { error in
            if error != nil {
                completion(error)
            } else {
                group.leave()
            }
            
            
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dataStore.getDataStoreDocument(ofType: .convoy, withID: id) { result in
                switch result {
                case .failure(let error):
                    completion(error)
                case .success(let doc):
                    for member in memberData {
                        doc.addSubgroupDocument(to: .members, newData: member) { error in
                            if error != nil {
                                completion(error)
                            }
                        }
                    }
                    completion(nil)
                }
            }
        }
    }
    
    private func formatCreationData(in data: [String:Any]) -> ([String:Any], [[String:Any]]) {
        let memberData: [String:Any] = [
            "start": data["start"]!,
            "startLocationPlaceName": data["startLocationPlaceName"]!,
            "friends": data["friends"]!
        ]
        var newData = data
        newData.removeValue(forKey: "start")
        newData.removeValue(forKey: "startLocationPlaceName")
        newData.removeValue(forKey: "friends")
        
        let formattedMemberData = createMemberData(from: memberData)
        
        return (newData, formattedMemberData)
    }
    
    private func createMemberData(from data: [String: Any]) -> [[String:Any]] {
        var memberData: [[String:Any]] = []
        let myUserData: [String:Any] = [
            "userUID": UserModel.shared.signedInUser!.userUID,
            "status": "not started",
            "start": data["start"]!,
            "startLocationPlaceName": data["startLocationPlaceName"]!
        ]
        
        memberData.append(myUserData)
        
        let friends: [String] = data["friends"]! as! [String]
        for friend in friends {
            let friendData: [String: Any] = [
                "userUID": friend,
                "status": "requested"
            ]
            memberData.append(friendData)
        }
        return memberData
    }
    
    func getConvoyInvites(onCompletion completion: @escaping (Result<[Convoy], Error>) -> Void) {
        let convoyGroup = DispatchGroup()
        if let user = UserModel.shared.signedInUser {
            
            let condition = DataStoreCondition(field: UserFields.userUID, op: FirebaseOperator.isEqualTo, value: user.userUID)
            dataStore.getDataStoreGroup(ofType: .convoyRequests, withConditions: [condition]) { [weak self] result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let docs):
                    var convoys: [Convoy] = []
                    for doc in docs {
                        guard let convoyID = doc.data()?["convoyID"] as? String else {
                            completion(.failure(FirestoreDocumentNotFoundError()))
                            return
                        }
                        
                        if let strongSelf = self {
                            convoyGroup.enter()
                            strongSelf.getConvoy(withID: convoyID) {[weak self] convoyResult in
                                switch convoyResult {
                                case .failure(let error):
                                    completion(.failure(error))
                                case .success(let c):
                                    if let strongSelf2 = self {
                                        strongSelf2.updateMembers(for: c) { convoy in
                                            convoys.append(convoy)
                                            convoyGroup.leave()
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }
                        
                    }
                    convoyGroup.notify(queue: DispatchQueue.main) {
                        completion(.success(convoys))
                    }
                }
            }
            
            
        } else {
            completion(.failure(NoUserSignedInError()))
        }
        
    }
    
    func getConvoy(withID id: String, onCompletion completion: @escaping (Result<Convoy, Error>) -> Void) {
        
        
        dataStore.getDataStoreDocument(ofType: .convoy, withID: id) { result in
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let doc):
                let convoyResult: Result<Convoy, Error> = doc.getAsType(type: .convoy)
                completion(convoyResult)
            }
        }
        
            
    }
    
    func updateMembers(for convoy: Convoy, onCompletion completion: @escaping (Convoy) -> Void ) {
        
        dataStore.getDataStoreDocument(ofType: .convoy, withID: convoy.convoyID!) { result in
            switch result {
            case .failure(_):
                return
            case .success(let doc):
                doc.getSubgroupDocument(ofType: .members, withConditions: []) { memberResult in
                    switch memberResult {
                    case .failure(_):
                        return
                        
                    case .success(let docs):
                        if let first = docs.first {
                            let final: Result<[ConvoyMember], Error> = type(of: first).extractTypeFrom(resultList: memberResult, ofType: .members)
                            
                            switch final {
                            case .failure(_):
                                return
                            case .success(let members):
                                convoy.members = members
                                completion(convoy)
                            }
                        }
                    }
                }
                
            }
        }
    
    }
    
    func commence(convoy: Convoy) {
        if let start = convoy.userMember?.start {
            let data: [String:Any] = [
                       "status" : "in progress",
                       "currentLocation" : start
                   ]
            updateUserMembership(for: convoy, withData: data)
        }
       
    }
    
    func arrived(convoy: Convoy) {
        let data: [String : Any] = [
            "status" : "arrived"
        ]
        
        updateUserMembership(for: convoy, withData: data)
    }
    
    func updateCurrentLocation(to location: CLLocation, for convoy: Convoy) {
        let data: [String : Any] = [
            "currentLocation" : [
                "long" : Double(location.coordinate.longitude),
                "lat" : Double(location.coordinate.latitude)
            ]
        ]
        updateUserMembership(for: convoy, withData: data)
    }
    
    func updateRoute(to route: [CLLocation], for convoy: Convoy) {
        var codableRoute = [[String : Double]]()
        
        for location in route {
            codableRoute.append([
                "long" : Double(location.coordinate.longitude),
                "lat" : Double(location.coordinate.latitude)
            ])
        }
        
        let data: [String : Any] = [
            "route" : codableRoute
        ]
        
        updateUserMembership(for: convoy, withData: data)
    }
    
}

class Convoy: Codable {
    var convoyID: String?
    var name: String
    var destination: [String: Double]
    var destinationPlaceName: String
    var members: [ConvoyMember]?
    var userMember: ConvoyMember? {
        get {
            members?.first() {
                if let user = UserModel.shared.signedInUser {
                    return $0.userUID == user.userUID
                } else {
                    return false
                }
            }
        }
    }
    
    
}

class ConvoyMember: Codable {
    var userUID: String
    var status: String
    var start: [String: Double]?
    var startLocationPlaceName: String?
    var currentLocation: [String: Double]?
    var route: [[String: Double]]?
}
