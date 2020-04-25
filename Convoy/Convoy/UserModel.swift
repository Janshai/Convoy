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
        db.collection("users").getDocuments() { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(.failure(err))
            } else {
                var users: [User] = []
                for document in querySnapshot!.documents {
                    if let strongSelf = self {
                        let result = strongSelf.convertUser(from: document)
                        switch result {
                        case .success(let user):
                            users += [user]
                        case .failure(let error):
                            completion(.failure(error))
                            return
                        }
                    }
                    
                }
                
                completion(.success(users))
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
    
    func getFriendRequests(onCompletion completion: @escaping (Result<[User], Error>) -> Void) {
        let userGroup = DispatchGroup()
        if let user = signedInUser {
            let query = db.collection("friendRequests").whereField("receiver", isEqualTo: user.userUID)
            
            query.getDocuments() { [weak self] (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        completion(.failure(err))
                    } else {
                        var users: [User] = []
                        for document in querySnapshot!.documents {
                            guard let sender = document.data()["sender"] as? String else {
                                completion(.failure(FirestoreDocumentNotFoundError()))
                                return
                            }
                            if let strongSelf = self {
                                userGroup.enter()
                                strongSelf.getUser(withID: sender) { result in
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
                        userGroup.notify(queue: DispatchQueue.main) {
                            completion(.success(users))
                        }
                    }
            }
        } else {
            completion(.failure(NoUserSignedInError()))
        }
        
    }
    
    func getUser(withID id: String, onCompletion completion: @escaping (Result<User, Error>) -> Void) {
        
        db.collection("users").whereField("userUID", isEqualTo: id).getDocuments() { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(.failure(err))
            } else {
                if querySnapshot!.documents.count != 1 {
                    completion(.failure(FirestoreDocumentNotFoundError()))
                } else {
                    if let strongSelf = self {
                        let result = strongSelf.convertUser(from: querySnapshot!.documents[0])
                        switch result {
                        case .success(let user):
                            completion(.success(user))
                            return
                        case .failure(let error):
                            completion(.failure(error))
                            return
                        }
                    }
                    
                }

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
