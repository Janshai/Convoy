//
//  DataStoreMock.swift
//  ConvoyTests
//
//  Created by Jack Adams on 12/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation
@testable import Convoy

class DataStoreMock: DataStore {
    
  
    func getDataStoreGroup(ofType type: DataStoreGroup, withConditions conditions: [DataStoreCondition], onCompletion completion: @escaping (Result<[DataStoreDocument], Error>) -> Void) {
        switch type {
        case .convoys:
            return
            
        case .users:
            if conditions.count == 0 {
                let users = Array(userStore.values)
                completion(.success(users.map({MockDataStoreDocument(id: $0.userUID, user: $0)})))
            }
        case .convoyRequests:
            
            let invites = inviteStore.filter() { pair in
                if conditions.count == 1 {
                    if pair.value["userUID"]! == conditions.first!.value as! String {
                        return true
                    }
                }
                return false
                
            }
            
            let docs = invites.map() { pair in
                return MockDataStoreDocument(id: String(pair.key), document: pair.value)
            }
            
            completion(.success(docs))
            
        case .friendRequests:
            if conditions.count == 1 {
                let condition = conditions.first!
                let requests = friendRequestStore.filter() { r in
                    if r.value.receiver == condition.value as! String {
                        return true
                    } else {
                        return false
                    }
                }
                let docs = requests.map({MockDataStoreDocument(id: $0.key, document: $0.value)})
                completion(.success(docs))
            }
            
        case .friends:
            if conditions.count == 1 {
                let condition = conditions.first!
                let friends = friendshipStore.filter() { f in
                    switch condition.field as! FriendFields {
                    case .friend1: return f.value.friend1 == condition.value as! String
                    case .friend2: return f.value.friend2 == condition.value as! String
                    }
                }
                let docs = friends.map({MockDataStoreDocument(id: $0.key, document: $0.value)})
                    completion(.success(docs))
            }
        default:
            
            return
        }
    }
    
    func getDataStoreDocument(ofType type: DataStoreGroup, withID id: String, onCompletion completion: @escaping (Result<DataStoreDocument, Error>) -> Void) {
        switch type {
        case .convoys:
            let convoy = convoyStore[id]
            if convoy != nil {
                let document = MockDataStoreDocument(id: id, document: convoy!)
                
                completion(.success(document))
            } else {
                completion(.failure(MockError()))
            }
            
        case .users:
            let user = userStore[id]
            if user != nil {
                let document = MockDataStoreDocument(id: id, user: user!)
                completion(.success(document))
            } else {
                completion(.failure(MockError()))
            }
        default: return
        }
    }
    
    func addDocument(to group: DataStoreGroup, withData data: [String : Any], onCompletion completion: @escaping (Error?) -> Void) -> String {
        switch group {
        case .convoys:
            let id = UUID().uuidString
            let convoy = Convoy(id: id, name: data["name"] as! String, destination: data["destination"] as! [String : Double], destinationPlaceName: data["destinationPlaceName"] as! String)
            convoyStore[id] = convoy
            completion(nil)
            return id
        case .friendRequests:
            input["friendRequest"] = data
            completion(nil)
            return "friendRequest"
            
        default:
            let error = MockError()
            completion(error)
            return error.localizedDescription
        }
    }
    
    func updateDataStoreDocument(ofType type: DataStoreGroup, withConditions conditions: [DataStoreCondition], newData data: [String : Any]) {
        
        
        switch type {
        case .friendRequests:
            var data : [String : String] = ["status" : data["status"] as! String]
            for condition in conditions {
                switch condition.field as! FriendRequestFields {
                case .receiver:
                    data["receiver"] = condition.value as! String
                    
                case .sender:
                    data["sender"] = condition.value as! String
                default:
                    return
                }
            }
            self.input["friendRequestUpdate"] = data
        default:
            return
        }
        
    }
    
    func getSubGroup(ofType type: DataStoreGroup, withConditions conditions: [DataStoreCondition], onCompletion completion: @escaping (Result<[DataStoreDocument], Error>) -> Void) {
        switch type {
        case .members:
            if conditions.count == 1 {
                let condition = conditions.first!
                var docs: [DataStoreDocument] = []
                for convoy in Array(convoyStore.values) {
                    let members = convoy.members!.filter() { member in
                        
                        return member.userUID == condition.value as! String
                        
                    }
                    docs += members.map() { member in
                        let doc = MockDataStoreDocument(id: member.userUID , document: member)
                        doc.parentDocID = convoy.convoyID
                        return doc
                        
                    }
                }
                completion(.success(docs))
            }
        default:
            completion(.failure(MockError()))
        }
    }
    
    func addDocument(to group: DataStoreGroup, newData data: [String : Any], onCompletion completion: @escaping (Error?) -> Void) -> String {
        
        switch group {
        case .convoys:
            let id = UUID().uuidString
            let convoy = Convoy(id: id, name: data["name"] as! String, destination: data["destination"] as! [String : Double], destinationPlaceName: data["destinationPlaceName"] as! String)
            convoyStore[id] = convoy
            completion(nil)
            return id
            
        default:
            completion(MockError())
            return MockError().localizedDescription
        }
        
    }
    
    func addMembers() {
        let convoy1 = convoyStore["1"]!
        let convoy2 = convoyStore["2"]!
        convoy1.members = [ConvoyMember(id: "2356", status: "not started"), ConvoyMember(id: "34", status: "requested")]
        
        convoy2.members = [ConvoyMember(id: "34", status: "not started"), ConvoyMember(id: "2356", status: "requested")]
    }
    
    var convoyStore = ["1": Convoy(id: "1", name: "dummyConvoy", destination: ["long": 569.765, "lat" : 0.9867],  destinationPlaceName: "a dummy location"), "2": Convoy(id: "2", name: "anotherDummy", destination: ["long": 569.765, "lat" : 0.9867], destinationPlaceName: "a dummy location")]
    
    var inviteStore = ["1" : ["userUID" : "34", "convoyID" : "1"], "2" : ["userUID" : "2356", "convoyID" : "2"]]
    
    var userStore = ["1" : User(displayName: "mike", email: "mike@me.com", userUID: "1"), "2": User(displayName: "kevin", email: "kevin@me.com", userUID: "2")]
    
    var friendRequestStore = ["1" : FriendRequest(sender: "2", receiver: "2356", status: "sent"), "2": FriendRequest(sender: "", receiver: "1", status: "sent")]
    
    var friendshipStore = ["1" : Friendship(friend1: "1", friend2: "2356"), "2": Friendship(friend1: "2356", friend2: "2")]
    
    var input = [String : Any]()
    
    
    
}
