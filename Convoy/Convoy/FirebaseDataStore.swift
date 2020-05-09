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
    
    func getSubGroup(ofType type: DataStoreGroup, withConditions conditions: [DataStoreCondition], onCompletion completion: @escaping (Result<[DataStoreDocument], Error>) -> Void) {
        let group = db.collectionGroup(type.rawValue)
        var query: Query?
        
        if !conditions.isEmpty {
            query = apply(conditions: conditions, to: group)
        } else {
            query = group
        }
        
        if let q = query {
            q.getDocuments() { snapshot, error in
                if let err = error {
                    completion(.failure(err))
                } else {
                    let documents = snapshot!.documents.map({FirebaseDataStoreDocument(document:$0)})
                    completion(.success(documents))
                }
            }
        } else {
            completion(.failure(InvalidDataStoreCondition()))
        }
        
    }
    
    func getDataStoreDocument(ofType type: DataStoreGroup, withID id: String, onCompletion completion: @escaping (Result<DataStoreDocument, Error>) -> Void) {
        
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
                        completion(.success(document))
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
                    completion(.success(document))
                }
            }
        }
        
        
        
    }
    
    func getDataStoreGroup(ofType type: DataStoreGroup, withConditions conditions: [DataStoreCondition], onCompletion completion: @escaping (Result<[DataStoreDocument], Error>) -> Void) {
        
        
        
        if let query = getQuery(for: type, withConditions: conditions) {
            query.getDocuments() { snapshot, error in
                
                if let err = error {
                    completion(.failure(err))
                } else {
                    var dStoreDocs: [DataStoreDocument] = []
                    for document in snapshot!.documents {
                        let dStoreDoc = FirebaseDataStoreDocument(document: document)
                        dStoreDocs.append(dStoreDoc)
                    }
                    
                    completion(.success(dStoreDocs))
                    
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
    
    private func apply(conditions: [DataStoreCondition], to collection: Query) -> Query? {
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
    
    func addDocument(to collection: DataStoreGroup, newData data: [String : Any], onCompletion completion: @escaping (Error?) -> Void) -> String {
        let ref = db.collection(collection.rawValue).addDocument(data: data) { error in
            completion(error)
        }
        return ref.documentID
    }
    
}

class FirebaseDataStoreDocument: DataStoreDocument {
    
    var id: String {
        return document.documentID
    }
    
    var parentDocID: String? {
        return document.reference.parent.parent?.documentID
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
    
    static func extractTypeFrom<T : Decodable>(resultList: Result<[DataStoreDocument], Error>, ofType type: DataStoreGroup) -> Result<[T], Error> {
        switch resultList {
        case .failure(let error):
            return .failure(error)
            
        case .success(let documents):
            var results: [Result<T, Error>] = []
            for document in documents {
                let value: Result<T, Error> = document.getAsType(type: type)
                results.append(value)
            }
            
            var values: [T] = []
            for r in results {
                switch r {
                case .success(let v):
                    values.append(v)
                case .failure(let error):
                    return .failure(error)
                }
            }
            
            return .success(values)
            
            
        }
    }
    
    func data() -> [String : Any]? {
        return document.data()
    }
    
    func getSubgroupDocument(ofType type: DataStoreGroup, withConditions conditions: [DataStoreCondition], onCompletion completion: @escaping (Result<[DataStoreDocument], Error>) -> Void) {
        
        var ref: Query = document.reference.collection(type.rawValue)
        
        for condition in conditions {
            let operation = condition.op as! FirebaseOperator
            switch operation {
            case .isEqualTo:
                ref = ref.whereField(condition.field.str, isEqualTo: condition.value)
            case .isGreaterThan:
                ref = ref.whereField(condition.field.str, isGreaterThan: condition.value)
            case .isLessThan:
                ref = ref.whereField(condition.field.str, isLessThan: condition.value)
            }
            
        }
        
        ref.getDocuments() { snapshot, error in
            if error != nil {
                completion(.failure(error!))
            }
            var documents: [DataStoreDocument] = []
            
            for doc in snapshot!.documents {
                documents.append(FirebaseDataStoreDocument(document: doc))
            }
            
            completion(.success(documents))
        }
        
    }
    
    func update(withData data: [String : Any]) {
        document.reference.updateData(data)
    }
    
    func addSubgroupDocument(to group: DataStoreGroup, newData data: [String: Any], onCompletion completion: @escaping (Error?) -> Void) {
        document.reference.collection(group.rawValue).addDocument(data: data) { error in
            completion(error)
        }
    }
    
}

enum FirebaseOperator: DataStoreOperator {
    case isEqualTo
    case isGreaterThan
    case isLessThan
}

struct InvalidDataStoreCondition: Error {
    
}
