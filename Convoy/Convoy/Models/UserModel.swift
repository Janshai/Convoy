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
    
    var dataStore: DataStore = FirebaseDataStore()
    var authService: AuthService = FirebaseAuthService()
    
    var signedInUser: User? {
        authService.currentUser
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
        
        dataStore.addDocument(to: .friendRequests, withData: friendRequest) { error in
            
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        dataStore.getDataStoreGroup(ofType: .users, withConditions: []) { result in
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let documents):
                if let first = documents.first {
                    let result: Result<[User], Error> = type(of: first).extractTypeFrom(resultList: result, ofType: .users)
                    completion(result)
                }
            }
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
        
        completion()
        
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
            
            let receiverCondition = DataStoreCondition(field: FriendRequestFields.receiver, op: FirebaseOperator.isEqualTo, value: user.userUID)
            userGroup.enter()
            dataStore.getDataStoreGroup(ofType: .friendRequests, withConditions: [receiverCondition]) { [weak self] result in
                
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let documents):
                    if let first = documents.first {
                        let newResult: Result<[FriendRequest], Error> = type(of: first).extractTypeFrom(resultList: result, ofType: .friendRequests)
                        switch newResult {
                        case .failure(let err):
                            completion(.failure(err))
                        case .success(let requests):
                            for request in requests {
                                guard let strongSelf = self else { return }
                                userGroup.enter()
                                strongSelf.dataStore.getDataStoreDocument(ofType: .users, withID: request.sender) { (result: Result<DataStoreDocument, Error>) in
                                    switch result {
                                    case .success(let doc):
                                        let userResult: Result<User, Error> = doc.getAsType(type: .users)
                                        switch userResult {
                                        case .failure(let e):
                                            completion(.failure(e))
                                        case .success(let user):
                                            users.append(user)
                                            userGroup.leave()
                                        }
                                        
                                    case .failure(let error):
                                        completion(.failure(error))
                                        return
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                }
                userGroup.leave()
                
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
        dataStore.getDataStoreGroup(ofType: .friends, withConditions: [condition]) {[weak self] result in
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let documents):
                if let first = documents.first {
                    let friendResult: Result<[Friendship], Error> = type(of: first).extractTypeFrom(resultList: result, ofType: .friends)
                    switch friendResult {
                    case .failure(let e):
                        completion(.failure(e))
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
                            strongSelf.dataStore.getDataStoreDocument(ofType: .users, withID: id) { userResult in
                                switch userResult {
                                case .success(let doc):
                                    let conversionResult: Result<User, Error> = doc.getAsType(type: .users)
                                    switch conversionResult {
                                    case .failure(let e2):
                                        completion(.failure(e2))
                                    case .success(let user):
                                        users.append(user)
                                        userGroup.leave()

                                    }
                                case .failure(let err):
                                    completion(.failure(err))
                                }
                                
                            }
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
        
        dataStore.getDataStoreDocument(ofType: .users, withID: id) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let doc):
                let userResult: Result<User, Error> = doc.getAsType(type: .users)
                completion(userResult)
            }
            
        }
        
    }
    
}

struct FirestoreDocumentNotFoundError: Error {
    
}

struct SelfReferenceNilError: Error {
    
}

struct NoUserSignedInError: Error {
    
}

class User: Codable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        if lhs.userUID == rhs.userUID, lhs.email == rhs.email {
            return true
        } else {
            return false
        }
    }
    
    var displayName: String
    var email: String
    var userUID: String
    var friends: [User]?
    
    init(displayName: String, email: String, userUID: String) {
        self.displayName = displayName
        self.email = email
        self.userUID = userUID
    }
    

    
}

class FriendRequest: Codable {
    var receiver: String
    var sender: String
    var status: String
    
    init (sender: String, receiver: String, status: String) {
        self.sender = sender
        self.receiver = receiver
        self.status = status
    }
}
class Friendship: Codable {
    var friend1: String
    var friend2: String
    
    init(friend1: String, friend2: String) {
        self.friend1 = friend1
        self.friend2 = friend2
    }
}
