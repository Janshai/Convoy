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
        
        db.collection("friendRequests").addDocument(data: friendRequest)
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
        
        db.collection("friendRequests").whereField("sender", isEqualTo: sender).whereField("receiver", isEqualTo: user.userUID).getDocuments() { [weak self] (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion()
            } else {
                let id = querySnapshot!.documents[0].documentID
                if let strongSelf = self {
                    strongSelf.db.collection("friendRequests").document(id).updateData([
                        "status" : newStatus]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            completion()
                            print("Document successfully updated")
                        }

                    }
                }
                
            }
            
        }
        
        
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
        userGroup.enter()
        db.collection("friends").whereField("friend1", isEqualTo: currentUser.userUID).getDocuments() { [weak self] (querySnapshot, err) in
            
            
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion(.failure(err))
            } else {
            
                for document in querySnapshot!.documents {
                    guard let friend = document.data()["friend2"] as? String else {
                        completion(.failure(FirestoreDocumentNotFoundError()))
                        return
                    }
                    if let strongSelf = self {
                        userGroup.enter()
                        strongSelf.getUser(withID: friend) { result in
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
                
                userGroup.leave()
            }
        }
        userGroup.enter()
        db.collection("friends").whereField("friend2", isEqualTo: currentUser.userUID).getDocuments() { [weak self] (querySnapshot, err) in
            
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion(.failure(err))
            } else {
                
                for document in querySnapshot!.documents {
                    
                    guard let friend = document.data()["friend1"] as? String else {
                        completion(.failure(FirestoreDocumentNotFoundError()))
                        return
                    }
                    if let strongSelf = self {
                        userGroup.enter()
                        strongSelf.getUser(withID: friend) { result in
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
                
                userGroup.leave()
            }
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
}
