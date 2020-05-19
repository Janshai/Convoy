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
    var convoyIDS = [String]()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
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
        
        
        
        for data in userData {
            db.collection("users").addDocument(data: data)
        }
        
        for data in friendData {
            db.collection("friends").addDocument(data: data)
        }
        
        var convoy = 1
        for data in convoyData {
            let id = db.collection("convoys").addDocument(data: data)
            convoyIDS.append(id.documentID)
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
        
        for data in friendRequests {
            db.collection("friendRequests").addDocument(data: data)
        }
        
        
    }
    
    func clearFirestore() {
      let semaphore = DispatchSemaphore(value: 0)
      let projectId = FirebaseApp.app()!.options.projectID!
      let url = URL(string: "http://localhost:8080/emulator/v1/projects/\(projectId)/databases/(default)/documents")!
      var request = URLRequest(url: url)
      request.httpMethod = "DELETE"
      let task = URLSession.shared.dataTask(with: request) { _,_,_ in
        print("Firestore cleared")
        semaphore.signal()
      }
      task.resume()
      semaphore.wait()
    }

    override func tearDown() {
        clearFirestore()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGetDataStoreGroup() {
        
        let dataStore = FirebaseDataStore()
        
        let expectation = XCTestExpectation(description: "dataStore does stuff and runs the callback closure")
        let expectationDB = XCTestExpectation(description: "check db data")
        
        dataStore.getDataStoreGroup(ofType: .users, withConditions: []) { [weak self] result in
            
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let docs):
                self?.db.collection("users").getDocuments() { snapshot, error in
                    
                    if let err = error {
                        XCTFail(err.localizedDescription)
                    } else {
                        XCTAssertEqual(snapshot!.documents.count, docs.count)
                        for document in snapshot!.documents {
                            let dbID = document.data()["userUID"] as! String
                            
                            XCTAssert(docs.contains(where: {
                                let dsID = $0.data()!["userUID"] as! String
                                return dbID == dsID
                            }))
                        }
                        expectationDB.fulfill()
                    }
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation, expectationDB], timeout: 10.0)
        
    }
    
    func testGetDataStoreDocument() {
        let dataStore = FirebaseDataStore()
        
        let expectation = XCTestExpectation(description: "dataStore does stuff and runs the callback closure")
        let id = convoyIDS.randomElement()
        dataStore.getDataStoreDocument(ofType: .convoys, withID: id!) { [weak self] result in
            
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let doc):
                
                let ref = self?.db.collection("convoys").document(id!)
                XCTAssertEqual(ref?.documentID, id!)
                XCTAssertEqual(doc.id, id!)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateDataStoreDocument() {
        let dataStore = FirebaseDataStore()
        
        let senderCondition = DataStoreCondition(field: FriendRequestFields.sender, op: FirebaseOperator.isEqualTo, value: "1")
        let receiverCondition = DataStoreCondition(field: FriendRequestFields.receiver, op: FirebaseOperator.isEqualTo, value: "3")
    
        
        dataStore.updateDataStoreDocument(ofType: .friendRequests, withConditions: [senderCondition, receiverCondition], newData: [FriendRequestFields.status.str : "accepted"])
        
        let expectation = XCTestExpectation(description: "dataStore does stuff and runs the callback closure")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.db.collection("friends").whereField("friend1", isEqualTo: "1").whereField("friend2", isEqualTo: "3").getDocuments() { snapshot, error in
                if let err = error {
                    XCTFail(err.localizedDescription)
                } else {
                    XCTAssertEqual(snapshot!.documents.count, 1)
                    XCTAssertNotNil(snapshot!.documents.first)
                    XCTAssertEqual(snapshot!.documents.count, 1)
                    expectation.fulfill()
                }
            }
        }
        
        
        wait(for: [expectation], timeout: 5.0)
        
    }
    
    func testGetSubgroup() {
//        let dataStore = FirebaseDataStore()
//
//        let expectation = XCTestExpectation(description: "dataStore does stuff and runs the callback closure")
//
//        dataStore.getSubGroup(ofType: .members, withConditions: []) { result in
//
//            switch result {
//            case .failure(let err):
//                XCTFail(err.localizedDescription)
//            case .success(let docs):
//
//                XCTAssertEqual(docs.count, 2)
//                for doc in docs {
//                    XCTAssertEqual(doc.data()!["userUID"] as! String, "2356")
//                }
//                expectation.fulfill()
//            }
//        }
//
//        wait(for: [expectation], timeout: 1.0)
    }
    
    func addDocument() {
        let dataStore = FirebaseDataStore()
        
        let expectation = XCTestExpectation(description: "dataStore does stuff and runs the callback closure")
        let expectationDB = XCTestExpectation(description: "checking db data matches")
        let data : [String : Any] = ["name" : ""]
        
        let id = dataStore.addDocument(to: .convoys, withData: data) { error in
            if error != nil {
                XCTFail(error!.localizedDescription)
            } else {
            
                expectation.fulfill()
            }
        }
        
        db.collection("convoys").document(id).getDocument() { snapshot, error in
            
            if let err = error {
                XCTFail(err.localizedDescription)
            } else {
                XCTAssert(snapshot!.exists)
                expectationDB.fulfill()
            }
            
        }
        wait(for: [expectation, expectationDB], timeout: 1.0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
