//
//  FirebaseDataStoreTests.swift
//  ConvoyTests
//
//  Created by Jack Adams on 15/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import XCTest
import FirebaseFirestoreSwift
import Firebase
@testable import Convoy

class FirebaseDataStoreTests: XCTestCase {
    
    var db = Firestore.firestore()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isPersistenceEnabled = false
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        
        let userData: [[String : Any]] = [[ "userUID" : "2356",
                                            "displayName" : "testCurrentUser",
                                            "email" : "current@test.com"],
                                          [ "userUID" : "1",
                                            "displayName" : "Bob",
                                            "email" : "bob@test.com"],
                                          [ "userUID" : "2",
                                            "displayName" : "Billy",
                                            "email" : "billy@test.com"],
                                          [ "userUID" : "3",
                                            "displayName" : "Shelly",
                                            "email" : "shelly@test.com"]]
        
        let convoyData: [[String : Any]] = [[ "name" : "adventure",
                                              "destination" : ["long" : 3.099, "lat" : 654.566],
                                              "destinationPlaceName" : "New Orleans"],
                                            [ "name" : "home",
                                              "destination" : ["long" : 3.099, "lat" : 654.566],
                                              "destinationPlaceName" : "Stockport"],
                                            [ "name" : "disney",
                                              "destination" : ["long" : 3.099, "lat" : 654.566],
                                              "destinationPlaceName" : "Disney World"]]
        
        let convoy1MemberData: [[String : Any]] = [["userUID" : "2356",
                                                    "status" : "not started",
                                                    "start" : ["long" : 3.099, "lat" : 654.566],
                                                    "startLocationPlaceName" : "Austin, Texas"],
                                                   ["userUID" : "1",
                                                    "status" : "requested"],
                                                   ["userUID" : "2",
                                                    "status" : "requested"]]
        let convoy2MemberData: [[String : Any]] = [["userUID" : "1",
                                                    "status" : "not started",
                                                    "start" : ["long" : 3.099, "lat" : 654.566],
                                                    "startLocationPlaceName" : "Houston, Texas"],
                                                   ["userUID" : "2356",
                                                    "status" : "requested"],
                                                   ["userUID" : "2",
                                                    "status" : "requested"]]
        let convoy3MemberData: [[String : Any]] = [["userUID" : "2356",
                                                    "status" : "not started",
                                                    "start" : ["long" : 3.099, "lat" : 654.566],
                                                    "startLocationPlaceName" : "Silicon Valley"],
                                                   ["userUID" : "2",
                                                    "status" : "not started",
                                                    "start" : ["long" : 3.099, "lat" : 654.566],
                                                    "startLocationPlaceName" : "Hollywood Boulevard"],
                                                   ["userUID" : "1",
                                                    "status" : "not started",
                                                    "start" : ["long" : 3.099, "lat" : 654.566],
                                                    "startLocationPlaceName" : "Neverland"]]
        
        let friendData : [[String : Any]] = [["friend1" : "2356",
                                              "friend2" : "1"],
                                             ["friend1" : "2356",
                                              "friend2" : "2"],
                                             ["friend1" : "1",
                                              "friend2" : "2"]]
        
        let friendRequests : [[String: Any]] = [["sender" : "1",
                                                 "receiver" : "3",
                                                 "status" : "sent"],
                                                ["sender" : "2356",
                                                 "receiver" : "3",
                                                 "status" : "sent"],
                                                ["sender" : "3",
                                                 "receiver" : "2",
                                                 "status" : "sent"]]
        
        let convoyRequests : [[String : Any]] = [["userUID" : "",
                                                  "convoyID" : "",
                                                  "status" : "sent"],
                                                 ["userUID" : "",
                                                  "convoyID" : "",
                                                  "status" : "sent"],
                                                 ["userUID" : "",
                                                  "convoyID" : "",
                                                  "status" : "sent"],
                                                 ["userUID" : "",
                                                  "convoyID" : "",
                                                  "status" : "sent"]]
        
        for data in userData {
            db.collection("users").addDocument(data: data)
        }
        
        for data in friendData {
            db.collection("friends").addDocument(data: data)
        }
        
        var convoy = 1
        for data in convoyData {
            let id = db.collection("convoys").addDocument(data: data)
            switch convoy {
            case 1:
                for memberData in convoy1MemberData {
                    db.collection("convoys").document(id.documentID).collection("members").addDocument(data: memberData)
                }
            case 2:
                for memberData in convoy2MemberData {
                    db.collection("convoys").document(id.documentID).collection("members").addDocument(data: memberData)
                }
            case 3:
                for memberData in convoy3MemberData {
                    db.collection("convoys").document(id.documentID).collection("members").addDocument(data: memberData)
                }
            default:
                return
            }
            convoy += 1
        }
        
        for data in convoyRequests {
            db.collection("convoyRequests").addDocument(data: data)
        }
        
        for data in friendRequests {
            db.collection("friendRequests").addDocument(data: data)
        }
        
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGetDataStoreGroup() {
        
        let dataStore = FirebaseDataStore()
        
        let expectation = XCTestExpectation(description: "dataStore does stuff and runs the callback closure")
        
        dataStore.getDataStoreGroup(ofType: .users, withConditions: []) { result in
            
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let docs):
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testGetDataStoreDocument() {
        let dataStore = FirebaseDataStore()
        
        let expectation = XCTestExpectation(description: "dataStore does stuff and runs the callback closure")
        
        dataStore.getDataStoreDocument(ofType: .convoys, withID: "") { result in
            
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let docs):
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateDataStoreDocument() {
        let dataStore = FirebaseDataStore()
        
        let senderCondition = DataStoreCondition(field: FriendRequestFields.sender, op: FirebaseOperator.isEqualTo, value: "")
        let receiverCondition = DataStoreCondition(field: FriendRequestFields.receiver, op: FirebaseOperator.isEqualTo, value: "")
        
        dataStore.updateDataStoreDocument(ofType: .friendRequests, withConditions: [senderCondition, receiverCondition], newData: ["status" : "accepted"])
    }
    
    func testGetSubgroup() {
        let dataStore = FirebaseDataStore()
        
        let expectation = XCTestExpectation(description: "dataStore does stuff and runs the callback closure")
        
        dataStore.getSubGroup(ofType: .members, withConditions: []) { result in
            
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let docs):
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func addDocument() {
        let dataStore = FirebaseDataStore()
        
        let expectation = XCTestExpectation(description: "dataStore does stuff and runs the callback closure")
        let data : [String : Any] = ["name" : ""]
        
        let id = dataStore.addDocument(to: .convoys, withData: data) { error in
            if error != nil {
                XCTFail(error!.localizedDescription)
            } else {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
