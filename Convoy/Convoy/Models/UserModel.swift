//
//  UserModel.swift
//  Convoy
//
//  Created by Jack Adams on 24/04/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


class UserModel {
    
    static let shared = UserModel()
    
    let db = Firestore.firestore()
    
    let dataStore = FirebaseDataStore()
    
    var signedInUser: User? {
        let user = Auth.auth().currentUser
        if let user = user {
            return User(displayName: user.displayName!, email: user.email!, userUID: user.uid)
        } else {
            return nil
        }
        
    }
    
    func sendFriendRequest(to user: User) {
        if signedInUser == nil {
            //throw
        }
        let friendRequest: [String: Any] = [
            "sender" : signedInUser!.userUID,
            "receiver": user.userUID,
            "status" : "sent"
        ]
        
        dataStore.addDocument(to: .friendRequests, withData: friendRequest)
    }
    
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        dataStore.getDataStoreGroup(ofType: .user, withConditions: []) { (result: Result<[User], Error>) in
            completion(result)
        }
    }
    
    func searchAllUsers(for searchTerm: String, onCompletion completion: @escaping (Result<[User], Error>) -> Void) {
        getAllUsers() { [weak self] result in
            switch result {
            case .success(let users):
                if let strongSelf = self {
                    completion(.success(strongSelf.filter(users: users, for: searchTerm)))
                } else {
                    completion(.failure(SelfReferenceNilError()))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func filter(users: [User], for searchString: String) -> [User] {
        
        
        return users.filter() { user in
            
            if user.userUID == signedInUser?.userUID {
                return false
            }
            
            if user.displayName.lowercased().contains(searchString.lowercased()) {
                return true
            } else {
                return false
            }
        }
    }
    
    private func convertUser(from doc: QueryDocumentSnapshot) -> Result<User, Error> {
        let result = Result {
            try doc.data(as: User.self)
        }
        
        switch result {
        case .success(let user):
            if let user = user {
                // A `User` value was successfully initialized from the DocumentSnapshot.
                return .success(user)
            } else {
                // A nil value was successfully initialized from the DocumentSnapshot,
                // or the DocumentSnapshot was nil.
                print("Document does not exist")
                return .failure(FirestoreDocumentNotFoundError())
            }
        case .failure(let error):
            // A `User` value could not be initialized from the DocumentSnapshot.
            print("Error decoding User: \(error)")
            return .failure(error)
        }


    }
    
    func updateFriendRequestStatus(to newStatus: String, for sender: String, onCompletion completion: @escaping () -> Void) {
        
        guard let user = signedInUser else {
            return
        }
        
        let data: [String : Any] = [
            FriendRequestFields.status.str : newStatus
        ]
        
        let conditions: [DataStoreCondition] = [
            DataStoreCondition(field: FriendRequestFields.sender, op: FirebaseOperator.isEqualTo, value: sender),
            DataStoreCondition(field: FriendRequestFields.receiver, op: FirebaseOperator.isEqualTo, value: user.userUID)
        ]
        
        dataStore.updateDataStoreDocument(ofType: .friendRequests, withConditions: conditions, newData: data)
        
    }
    
    func searchFriendRequests(for searchTerm: String, onCompletion completion: @escaping (Result<[User], Error>) -> Void) {
        getFriends() { [weak self] result in
            switch result {
            case .success(let users):
                if let strongSelf = self {
                    completion(.success(strongSelf.filter(users: users, for: searchTerm)))
                } else {
                    completion(.failure(SelfReferenceNilError()))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }

    }
    
    func getFriendRequests(onCompletion completion: @escaping (Result<[User], Error>) -> Void) {
        let userGroup = DispatchGroup()
        if let user = signedInUser {
            var users: [User] = []
            
            let senderCondition = DataStoreCondition(field: FriendRequestFields.receiver, op: FirebaseOperator.isEqualTo, value: user.userUID)
            dataStore.getDataStoreGroup(ofType: .friendRequests, withConditions: [senderCondition]) { [weak self] (result: Result<[FriendRequest], Error>) in
                
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let requests):
                    
                    for request in requests {
                        guard let strongSelf = self else { return }
                        userGroup.enter()
                        strongSelf.dataStore.getDataStoreDocument(ofType: .user, withID: request.sender) { (result: Result<User, Error>) in
                            switch result {
                            case .success(let user):
                                users += [user]
                                userGroup.leave()
                            case .failure(let error):
                                completion(.failure(error))
                                return
                            }
                        }
                    }
                }
                
            }
        
            userGroup.notify(queue: DispatchQueue.main) {
                completion(.success(users))
            }
        } else {
            completion(.failure(NoUserSignedInError()))
        }
        
    }
    
    func getFriends(onCompletion completion: @escaping (Result<[User], Error>) -> Void) {
        let userGroup = DispatchGroup()
        guard let currentUser = signedInUser else {
            completion(.failure(NoUserSignedInError()))
            return
        }
        var users: [User] = []
        
        let condition1 = DataStoreCondition(field: FriendFields.friend1, op: FirebaseOperator.isEqualTo, value: currentUser.userUID)
        let condition2 = DataStoreCondition(field: FriendFields.friend2, op: FirebaseOperator.isEqualTo, value: currentUser.userUID)
        
        userGroup.enter()
        getFriends(with: condition1) { result in
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let u):
                users += u
            }
            
            userGroup.leave()
        }
        
        userGroup.enter()
        getFriends(with: condition2) { result in
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let u):
                users += u
            }
            
            userGroup.leave()
        }
        
        userGroup.notify(queue: DispatchQueue.main) {
            completion(.success(users))
        }
    }
    
    private func getFriends(with condition: DataStoreCondition, onCompletion completion: @escaping (Result<[User], Error>) -> Void) {
        
        let userGroup = DispatchGroup()
        var users: [User] = []
        userGroup.enter()
        dataStore.getDataStoreGroup(ofType: .friends, withConditions: [condition]) {[weak self] (result: Result<[Friendship], Error>) in
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let friendships):
                for friend in friendships {
                    guard let strongSelf = self else {
                        return
                    }
                    
                    userGroup.enter()
                    var id: String
                    if condition.field.str == FriendFields.friend1.str {
                        id = friend.friend2
                    } else {
                        id = friend.friend1
                    }
                    strongSelf.dataStore.getDataStoreDocument(ofType: .user, withID: id) { (userResult: Result<User, Error>) in
                        switch userResult {
                        case .success(let user):
                            users.append(user)
                            userGroup.leave()
                        case .failure(let err):
                            completion(.failure(err))
                        }
                        
                    }
                }
            }
            
            userGroup.leave()
            
        }
        
        userGroup.notify(queue: DispatchQueue.main) {
            completion(.success(users))
        }
        
    }
    
    func getUser(withID id: String, onCompletion completion: @escaping (Result<User, Error>) -> Void) {
        
        dataStore.getDataStoreDocument(ofType: .user, withID: id) { (result: Result<User, Error>) in
            completion(result)
        }
        
    }
    
}

struct FirestoreDocumentNotFoundError: Error {
    
}

struct SelfReferenceNilError: Error {
    
}

struct NoUserSignedInError: Error {
    
}

class User: Codable {
    var displayName: String
    var email: String
    var userUID: String
    var friends: [User]?
    
    init(displayName: String, email: String, userUID: String) {
        self.displayName = displayName
        self.email = email
        self.userUID = userUID
    }
    
    
    fileprivate func populateFriends() {
        return
    }
}

class FriendRequest: Codable {
    var receiver: String
    var sender: String
    var status: String
}
class Friendship: Codable {
    var friend1: String
    var friend2: String

}
