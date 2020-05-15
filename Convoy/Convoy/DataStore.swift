//
//  DataLoader.swift
//  Convoy
//
//  Created by Jack Adams on 08/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import Foundation

protocol DataStore {
    
    
    func getDataStoreGroup(ofType: DataStoreGroup, withConditions: [DataStoreCondition], onCompletion: @escaping (Result<[DataStoreDocument], Error>) -> Void)
    
    
    func getDataStoreDocument(ofType: DataStoreGroup, withID: String, onCompletion: @escaping (Result<DataStoreDocument, Error>) -> Void)
    
    func updateDataStoreDocument(ofType: DataStoreGroup, withConditions: [DataStoreCondition], newData: [String : Any])
    
    func getSubGroup(ofType: DataStoreGroup, withConditions: [DataStoreCondition], onCompletion: @escaping (Result<[DataStoreDocument], Error>) -> Void)
    
    func addDocument(to: DataStoreGroup, withData: [String : Any], onCompletion completion: @escaping (Error?) -> Void) -> String
    
}

enum DataStoreGroup: String {
    case convoys
    case users
    case friendRequests
    case convoyRequests
    case friends
    case members
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
    static func extractTypeFrom<T : Decodable>(resultList: Result<[DataStoreDocument], Error>, ofType: DataStoreGroup) -> Result<[T], Error>
    
    var id: String { get }
    
    var parentDocID: String? {get}
    
    func getAsType<T: Decodable>(type: DataStoreGroup) -> Result<T, Error>
    
    func data() -> [String: Any]?
    
    func getSubgroupDocument(ofType: DataStoreGroup, withConditions: [DataStoreCondition], onCompletion: @escaping (Result<[DataStoreDocument], Error>) -> Void)
    
    func update(withData: [String : Any])
    
    func addSubgroupDocument(to: DataStoreGroup, newData: [String: Any], onCompletion: @escaping (Error?) -> Void)
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

enum MemberFields: String, DataStoreField {
    
    var str: String {
        return self.rawValue
    }
    case userUID
}
