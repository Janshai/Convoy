//
//  MockDataStoreDocument.swift
//  ConvoyTests
//
//  Created by Jack Adams on 12/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation
@testable import Convoy

class MockDataStoreDocument: DataStoreDocument {
    static var testingUpdateMembers = false
    
    static func extractTypeFrom<T>(resultList result: Result<[DataStoreDocument], Error>, ofType type: DataStoreGroup) -> Result<[T], Error> where T : Decodable {
        
        switch type {
        case .members:
            print(result)
            switch result {
            case .success(let docs):
                var members: [T] = []
                for doc in docs {
                    members.append(ConvoyMember(id: doc.id, status: doc.data()!["status"] as! String) as! T)
                }
                return .success(members)
            default:
                return .failure(MockError())
            }
        case .friendRequests:
            switch result {
            case .success(let docs):
                var frs: [T] = []
                
                for doc in docs {
                    frs.append(FriendRequest(sender: doc.data()!["sender"] as! String, receiver: doc.data()!["receiver"] as! String, status: doc.data()!["status"] as! String) as! T)
                }
                return .success(frs)
            default:
                return .failure(MockError())
            }
        case .friends:
            switch result {
            case .success(let docs):
                var friends: [T] = []
                
                for doc in docs {
                    friends.append(Friendship(friend1: doc.data()!["friend1"] as! String, friend2: doc.data()!["friend2"] as! String) as! T)
                }
                
                return .success(friends)
                
            default: return .failure(MockError())
            }
        case .users:
            
            switch result {
            case .success(let docs):
                var users: [T] = []
                for doc in docs {
                    users.append(User(displayName: doc.data()!["displayName"] as! String, email: doc.data()!["email"] as! String, userUID: doc.data()!["userUID"] as! String) as! T)
                }
                
                return .success(users)
            case .failure(let error):
                return .failure(error)
            }
            
            
        default:
            return .failure(MockError())
        }
        
    }
    
    init(id: String, document: Convoy) {
        self.id = id
        self.document = ["convoyID": id, "destination" : document.destination, "destinationPlaceName": document.destinationPlaceName, "name": document.name]
        if let members = document.members {
            self.document["members"] = members
        }
        
    }
    
    init (id: String, user: User) {
        self.id = id
        self.document = ["userUID" : id, "displayName" : user.displayName, "email" : user.email]
    }
    
    init(id: String, document: FriendRequest) {
        self.id = id
        
        self.document = ["sender": document.sender,
                          "receiver" : document.receiver,
                          "status" : document.status]
    }
    
    init(id: String, document: Friendship) {
        self.id = id
        self.document = ["friend1" : document.friend1,
                         "friend2" : document.friend2]
    }
    
    init(id: String, document: ConvoyMember) {
        self.id = id
        self.document = ["userUID" : document.userUID, "status" : document.status]
    }
    
    init (id: String, document: [String :String]) {
        self.id = id
        self.document = document
    }
    private var document : [String: Any]
    
    var id: String
    
    var parentDocID: String?
    
    func getAsType<T>(type: DataStoreGroup) -> Result<T, Error> where T : Decodable {
        switch type {
        case .convoys:
            let convoy = Convoy(id: self.id, name: document["name"] as! String, destination: document["destination"] as! [String : Double], destinationPlaceName: document["destinationPlaceName"] as! String)
            if let members = document["members"] as? [ConvoyMember] {
                convoy.members = members
            }
            
            if T.self == Convoy.self {
                return .success(convoy as! T)
            } else {
                return .failure(MockError())
            }
        case .users:
            let user = User(displayName: self.document["displayName"] as! String, email: self.document["email"] as! String, userUID: self.document["userUID"] as! String)
            
            if T.self == User.self {
                return .success(user as! T)
            } else {
                return .failure(MockError())
            }
        default:
            return.failure(MockError())
            
        }
    }
    
    func data() -> [String : Any]? {
        return self.document
    }
    
    func getSubgroupDocument(ofType type: DataStoreGroup, withConditions: [DataStoreCondition], onCompletion completion: @escaping (Result<[DataStoreDocument], Error>) -> Void) {
        
        switch type {
        case .members:
            var docs: [MockDataStoreDocument] = []
            if let members = self.document["members"] as? [ConvoyMember] {
                
                docs = members.map({MockDataStoreDocument(id: $0.userUID, document: $0)})
                
            } else if !MockDataStoreDocument.testingUpdateMembers {
                docs = Array(memberStore.values).map({MockDataStoreDocument(id: $0.userUID, document: $0)})
            }
            
            
            completion(.success(docs))
            
            
        default:
            return
        }
        
    }
    
    func update(withData data: [String : Any]) {
        self.document.merge(data, uniquingKeysWith: {(_, new) in new})
        
    }
    
    func addSubgroupDocument(to group: DataStoreGroup, newData data: [String : Any], onCompletion completion: @escaping (Error?) -> Void) {
        
        switch group {
        case .members:
            let id = data["userUID"] as! String
            let member = ConvoyMember(id: id, status: data["status"] as! String)
            if let start = data["start"] as? [String : Double] {
                member.start = start
            }
            
            if let name = data["startLocationPlaceName"] as? String {
                member.startLocationPlaceName = name
            }
            memberStore[id] = member
            MockDataStoreDocument.memberStoreState = memberStore
            completion(nil)
            return
        default:
            completion(MockError())
            return
            
        }
        
    }
    
    var memberStore = ["2356": ConvoyMember(id: "2356", status: "not started"), "34" : ConvoyMember(id: "34", status: "requested")]
    
    static var memberStoreState = [String : ConvoyMember]()
    
    
}

class MockError: Error {
    
}

class MockAuthService: AuthService {
    var currentUser: User? {
        return User(displayName: "testUser", email: "testUser@unitTests.com", userUID: "2356")
    }
    
    
}
