//
//  DataLoader.swift
//  Convoy
//
//  Created by Jack Adams on 08/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation

protocol DataStore {
    
    func getDataStoreGroup<T: Decodable>(ofType: DataStoreGroup, withConditions: [DataStoreCondition], onCompletion: @escaping (Result<[T], Error>) -> Void)
    
    
    func getDataStoreDocument<T: Decodable>(ofType: DataStoreGroup, withID: String, onCompletion: @escaping (Result<T, Error>) -> Void)
    
    func addDocument(to: DataStoreGroup, withData: [String : Any])
    
    func updateDataStoreDocument(ofType: DataStoreGroup, withConditions: [DataStoreCondition], newData: [String : Any])
    // func getSubGroup
}

enum DataStoreGroup: String {
    case convoy
    case user
    case friendRequests
    case convoyRequests
    case friends
}

class DataStoreCondition {
    var field: DataStoreField
    var op: DataStoreOperator
    var value: Any
    
    init(field: DataStoreField, op: DataStoreOperator, value: Any) {
        self.field = field
        self.op = op
        self.value = value
    }
}

protocol DataStoreField {
    
    var str: String { get }
    
}

protocol DataStoreOperator {
    
}

protocol DataStoreDocument {
    
    var id: String { get }
    
    func getAsType<T: Decodable>(type: DataStoreGroup) -> Result<T, Error>
}

enum ConvoyFields: String, DataStoreField {
    var str: String {
        return self.rawValue
    }
    
    case name
    case destination
    case destinationPlaceName
    
}

enum UserFields: String, DataStoreField {
    var str: String {
        return self.rawValue
    }
    
    case displayName
    case email
    case userUID
    
}

enum FriendRequestFields: String, DataStoreField {
    var str: String {
        return self.rawValue
    }
    
    case receiver
    case sender
    case status
}

enum FriendFields: String, DataStoreField {
    var str: String {
        return self.rawValue
    }
    
    case friend1
    case friend2
}
