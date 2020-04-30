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

class ConvoyModel{
    
    
    static var shared = ConvoyModel()
    let db = Firestore.firestore()
    
    func getConvoys(onCompletion completion: @escaping (Result<[Convoy], Error>) -> Void) {
        let group = DispatchGroup()
        var convoys: [Convoy] = []

        guard let user = UserModel.shared.signedInUser else {
            completion(.failure(NoUserSignedInError()))
            return
        }
        group.enter()
        db.collectionGroup("members").whereField("userUID", isEqualTo: user.userUID).getDocuments() { [weak self] snapshot, error in
            if error != nil {
                completion(.failure(error!))
                return
            } else {
                                for document in snapshot!.documents {
                    let convoyRef = document.reference.parent.parent
                    if let ref = convoyRef, let strongSelf = self {
                        group.enter()
                        strongSelf.getConvoy(withID: ref.documentID) { result in
                            switch result {
                            case .failure(let error):
                                completion(.failure(error))
                                return
                            case .success(let convoy):
                                convoys.append(convoy)
                                group.leave()
                            }
                        }
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(.success(convoys))
        }
    }
    
    func acceptInvite(to convoy: Convoy, withStartLocation data: [String: Any]) {
        let convoyRef = db.collection("convoys").document(convoy.convoyID!)
        guard let user = UserModel.shared.signedInUser else {
            return
        }
        var mutatableData = data
        mutatableData["status"] = "not started"
        convoyRef.collection("members").whereField("userUID", isEqualTo: user.userUID).getDocuments() { snapshot, error in
            if error != nil {
                return
            } else {
                let document = snapshot?.documents.first
                let id = document?.documentID
                convoyRef.collection("members").document(id!).updateData(mutatableData)
            }
        }
    }
    
    func declineInvite(to convoy: Convoy) {
        let convoyRef = db.collection("convoys").document(convoy.convoyID!)
        guard let user = UserModel.shared.signedInUser else {
            return
        }
        let data = [
            "status": "declined"
        ]
        
        convoyRef.collection("members").whereField("userUID", isEqualTo: user.userUID).getDocuments() { snapshot, error in
            if error != nil {
                return
            } else {
                let document = snapshot?.documents.first
                let id = document?.documentID
                convoyRef.collection("members").document(id!).updateData(data)
            }
        }
    }
    
    func createConvoy(from data: [String:Any], onCompletion completion: @escaping (Error?) -> Void) {
        var newData: [String: Any]
        var memberData: [[String:Any]]
        (newData, memberData) = formatCreationData(in: data)
        
        let group = DispatchGroup()
        group.enter()
        let id = db.collection("convoys").addDocument(data: newData) { error in
            if error != nil {
                completion(error)
                return
            } else {
                group.leave()
            }
            
        }
        
        group.notify(queue: DispatchQueue.main) {
            for member in memberData {
                id.collection("members").addDocument(data: member) { error in
                    if error != nil {
                        completion(error)
                    }
                }
            }
            completion(nil)
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
            let query = db.collection("convoyRequests").whereField("userUID", isEqualTo: user.userUID)
            
            query.getDocuments() { [weak self] (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        completion(.failure(err))
                    } else {
                        var convoys: [Convoy] = []
                        for document in querySnapshot!.documents {
                            print("here1")
                            guard let convoyID = document.data()["convoyID"] as? String else {
                                completion(.failure(FirestoreDocumentNotFoundError()))
                                return
                            }
                            if let strongSelf = self {
                                print("here2")
                                convoyGroup.enter()
                                strongSelf.getConvoy(withID: convoyID) { [weak self] result in
                                    switch result {
                                    case .success(let convoy):
                                        if let strongSelf2 = self {
                                            strongSelf2.initialiseMembers(for: convoy) { c in
                                                convoys += [c]
                                                convoyGroup.leave()
                                            }
                                        }
                                        
                                        
                                    case .failure(let error):
                                        completion(.failure(error))
                                        return
                                    }
                                    
                                    
                                }
                            }
                            
                        }
                        convoyGroup.notify(queue: DispatchQueue.main) {
                            print("here4")
                            completion(.success(convoys))
                        }
                    }
            }
        } else {
            completion(.failure(NoUserSignedInError()))
        }
        
    }
    
    func getConvoy(withID id: String, onCompletion completion: @escaping (Result<Convoy, Error>) -> Void) {
        let ref = db.collection("convoys").document(id)
        ref.getDocument() { [weak self] document, error in
            if error != nil {
                completion(.failure(error!))
            } else {
                if let doc = document, let strongSelf = self {
                    completion(strongSelf.convertConvoy(from: doc))
                } else {
                    completion(.failure(FirestoreDocumentNotFoundError()))
                }
            }
            
        }
    }
    
    private func convertConvoy(from doc: DocumentSnapshot) -> Result<Convoy, Error> {
        let result = Result {
            try doc.data(as: Convoy.self)
        }
        
        switch result {
        case .success(let convoy):
            if let convoy = convoy {
                convoy.convoyID = doc.documentID
                
                // A `User` value was successfully initialized from the DocumentSnapshot.
                return .success(convoy)
            } else {
                // A nil value was successfully initialized from the DocumentSnapshot,
                // or the DocumentSnapshot was nil.
                print("Document does not exist")
                return .failure(FirestoreDocumentNotFoundError())
            }
        case .failure(let error):
            // A `User` value could not be initialized from the DocumentSnapshot.
            print("Error decoding Convoy: \(error)")
            return .failure(error)
        }


    }
    
    func initialiseMembers(for convoy: Convoy, onCompletion completion: @escaping (Convoy) -> Void) {
        db.collection("convoys").document(convoy.convoyID!).collection("members").getDocuments() { snapshot, error in
            if error != nil {
                return
            }
            
            
            for document in snapshot!.documents {
                let result = Result {
                    try document.data(as: ConvoyMember.self)
                }
                
                switch result {
                case .success(let member):
                    convoy.members?.append(member!)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            completion(convoy)
        }
    }
    
}

class Convoy: Codable {
    var convoyID: String?
    var name: String
    var destination: [String: Double]
    var destinationPlaceName: String
    var members: [ConvoyMember]?
    
    
}

class ConvoyMember: Codable {
    var userUID: String
    var status: String
    var start: [String: Double]
    var startLocationPlaceName: String
}
