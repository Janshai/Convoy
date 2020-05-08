//
//  FirebaseDataStore.swift
//  Convoy
//
//  Created by Jack Adams on 08/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


class FirebaseDataStore: DataStore {
    
    private let db = Firestore.firestore()
    
    func getDataStoreDocument<T: Decodable>(ofType type: DataStoreGroup, withID id: String, onCompletion completion: @escaping (Result<T, Error>) -> Void) {
        
        if type == .user {
            
            let query = getQuery(for: type, withConditions: [DataStoreCondition(field: UserFields.userUID, op: FirebaseOperator.isEqualTo, value: id)])!
            query.getDocuments() { snapshot, error in
                if let err = error {
                    completion(.failure(err))
                } else {
                    if snapshot!.documents.count != 1 {
                        completion(.failure(FirestoreDocumentNotFoundError()))
                    } else {
                        let document = FirebaseDataStoreDocument(document: snapshot!.documents.first!)
                        completion(document.getAsType(type: type))
                    }
                }
            }
                
            
        } else {
            let ref = db.collection(type.rawValue).document(id)
            ref.getDocument() {snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let document = FirebaseDataStoreDocument(document: snapshot!)
                    completion(document.getAsType(type: type))
                }
            }
        }
        
        
        
    }
    
    func getDataStoreGroup<T:Decodable>(ofType type: DataStoreGroup, withConditions conditions: [DataStoreCondition], onCompletion completion: @escaping (Result<[T], Error>) -> Void) {
        
        
        
        if let query = getQuery(for: type, withConditions: conditions) {
            query.getDocuments() { snapshot, error in
                
                if let err = error {
                    completion(.failure(err))
                } else {
                    var results: [Result<T, Error>] = []
                    for document in snapshot!.documents {
                        let dStoreDoc = FirebaseDataStoreDocument(document: document)
                        let value: Result<T, Error> = dStoreDoc.getAsType(type: type)
                        results.append(value)
                    }
                    var values: [T] = []
                    results.forEach() {
                        switch $0 {
                        case .success(let v):
                            values.append(v)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                    
                    if values.count == results.count {
                        completion(.success(values))
                    }
                }
            }
        } else {
            completion(.failure(InvalidDataStoreCondition()))
        }
        
    }
    
    private func getQuery(for type: DataStoreGroup, withConditions conditions: [DataStoreCondition]) -> Query? {
        let collection = db.collection(type.rawValue)
        var query: Query?
        if !conditions.isEmpty {
            query = apply(conditions: conditions, to: collection)
        } else {
            query = collection
        }
        
        return query
    }
    
    private func apply(conditions: [DataStoreCondition], to collection: CollectionReference) -> Query? {
        var query: Query?
        for condition in conditions {
            if query != nil {
                query = apply(singleCondition: condition, to: query!)
            } else {
                query = apply(singleCondition: condition, to: collection)
            }
            
            if query == nil {
                break
            }
        }
        
        return query
        
    }
    
    private func apply(singleCondition condition: DataStoreCondition, to query: Query) -> Query? {
        if let op = condition.op as? FirebaseOperator {
            switch op {
            case .isEqualTo:
                return query.whereField(condition.field.str, isEqualTo: condition.value)
            case .isGreaterThan:
                return query.whereField(condition.field.str, isLessThan: condition.value)
            case .isLessThan:
                return query.whereField(condition.field.str, isLessThan: condition.value)
            }
        } else {
            return nil
        }
    }

    func addDocument(to collection: DataStoreGroup, withData data: [String : Any]) {
        db.collection(collection.rawValue).addDocument(data: data)
    }
    
    func updateDataStoreDocument(ofType type: DataStoreGroup, withConditions conditions: [DataStoreCondition], newData data : [String : Any]) {
        
        if let query = getQuery(for: type, withConditions: conditions) {
            query.getDocuments() { [weak self] snapshot, error in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    for document in snapshot!.documents {
                        guard let strongSelf = self else { return }
                        strongSelf.db.collection(type.rawValue).document(document.documentID).updateData(data)
                    }
                }
            }
        }
        
    }
    
}

class FirebaseDataStoreDocument: DataStoreDocument {
    
    var id: String {
        return document.documentID
    }
    
    var document: DocumentSnapshot
    
    init(document: DocumentSnapshot) {
        self.document = document
    }
    
    func getAsType<T : Decodable>(type: DataStoreGroup) -> Result<T, Error> {
        
        var value: T?
        do {
            value = try document.data(as: T.self)
        } catch  {
            return .failure(error)
        }
        
        if type == .convoy, let convoy = value! as? Convoy {
            convoy.convoyID = self.id
        }
        
        return .success(value!)
    }
    
    
}

enum FirebaseOperator: DataStoreOperator {
    case isEqualTo
    case isGreaterThan
    case isLessThan
}

struct InvalidDataStoreCondition: Error {
    
}
