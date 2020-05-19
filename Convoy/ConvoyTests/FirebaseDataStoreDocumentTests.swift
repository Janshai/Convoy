//
//  FirebaseDataStoreDocumentTests.swift
//  ConvoyTests
//
//  Created by Jack Adams on 17/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import XCTest
import Firebase
@testable import Convoy

class FirebaseDataStoreDocumentTests: XCTestCase {
    var db: Firestore!
    var convoyIDS = [String]()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isPersistenceEnabled = false
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
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
        db = nil
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
    
    func testData() {
        let expectation = XCTestExpectation(description: "get data from db and test document")
        db.collection("users").whereField("userUID", isEqualTo: "2356").getDocuments() { snapshot, err in
            if let error = err {
                XCTFail(error.localizedDescription)
            } else {
                let fbDoc = FirebaseDataStoreDocument(document: snapshot!.documents.first!)
                guard let data = fbDoc.data() else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(data["displayName"] as! String, "testCurrentUser")
                XCTAssertEqual(data["email"] as! String, "current@test.com")
                expectation.fulfill()
            }
            
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testID() {
        
        let expectation = XCTestExpectation(description: "get data from db and test document")
        db.collection("convoys").whereField("name", isEqualTo: "adventure").getDocuments() { snapshot, err in
            if let error = err {
                XCTFail(error.localizedDescription)
            } else {
                XCTAssertEqual(snapshot!.documents.count, 1)
                let fbDoc = FirebaseDataStoreDocument(document: snapshot!.documents.first!)
                XCTAssertEqual(fbDoc.id, snapshot!.documents.first!.documentID)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testParentDocID() {
        let expectation = XCTestExpectation(description: "get data from db and test document")
        db.collection("convoys").whereField("name", isEqualTo: "adventure").getDocuments() { [weak self] snapshot, err in
            if let error = err {
                XCTFail(error.localizedDescription)
            } else {
                XCTAssertEqual(snapshot!.documents.count, 1)
                let id = snapshot!.documents.first!.documentID
                self?.db.collection("convoys").document(id).collection("members").whereField("userUID", isEqualTo: "2356")
                    .getDocuments() { snapshot, error in
                        if let err = error {
                            XCTFail(err.localizedDescription)
                        } else {
                            XCTAssertEqual(snapshot!.documents.count, 1)
                            let fbDoc = FirebaseDataStoreDocument(document: snapshot!.documents.first!)
                            XCTAssertEqual(fbDoc.parentDocID, id)
                            expectation.fulfill()
                        }
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testExtractType() {
        
        let expectation = XCTestExpectation(description: "get data from db and test document")
        db.collection("convoys").getDocuments() { snapshot, error in
            if let err = error {
                XCTFail(err.localizedDescription)
            } else {
                let docs = snapshot!.documents.map({FirebaseDataStoreDocument(document: $0)})
                let final : Result<[Convoy], Error> = FirebaseDataStoreDocument.extractTypeFrom(resultList: .success(docs), ofType: .convoys)
                switch final {
                case .failure(let e):
                    XCTFail(e.localizedDescription)
                case .success(let convoys):
                    XCTAssertEqual(convoys.count, docs.count)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testGetAsType() {
        
        let expectation = XCTestExpectation(description: "get data from db and test document")
        db.collection("convoys").whereField("name", isEqualTo: "adventure").getDocuments() { snapshot, err in
            if let error = err {
                XCTFail(error.localizedDescription)
            } else {
                let doc = FirebaseDataStoreDocument(document: snapshot!.documents.first!)
                let result: Result<Convoy, Error> = doc.getAsType(type: .convoys)
                switch result {
                case .failure(let e):
                    XCTFail(e.localizedDescription)
                    return
                case .success(let convoy):
                    XCTAssertEqual(convoy.name, "adventure")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testUpdate() {
        let expectation = XCTestExpectation(description: "get data from db and test document")
        db.collection("convoys").whereField("name", isEqualTo: "adventure").getDocuments() { [weak self] snapshot, err in
            if let error = err {
                XCTFail(error.localizedDescription)
            } else {
                XCTAssertEqual(snapshot!.documents.count, 1)
                let id = snapshot!.documents.first!.documentID
                self?.db.collection("convoys").document(id).collection("members").whereField("userUID", isEqualTo: "2356")
                    .getDocuments() { [weak self] snapshot, error in
                        if let err = error {
                            XCTFail(err.localizedDescription)
                        } else {
                            XCTAssertEqual(snapshot!.documents.count, 1)
                            let fbDoc = FirebaseDataStoreDocument(document: snapshot!.documents.first!)
                            let data : [String : Any] = [
                                "status" : "in progress",
                                "currentLocation" : [
                                    "long" : 45.678,
                                    "lat" : 5677.567
                                ]
                            ]
                            fbDoc.update(withData: data)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                            
                                self?.db.collection("convoys").document(id).collection("members").document(fbDoc.id)
                                    .getDocument() { snapshot, error2 in
                                        if let err2 = error2 {
                                            XCTFail(err2.localizedDescription)
                                        } else {
                                            guard let member = snapshot?.data() else {
                                                XCTFail()
                                                return
                                            }
                                            XCTAssertEqual(member["status"] as! String, data["status"] as! String)
                                            XCTAssertEqual(member["currentLocation"] as! [String : Double], data["currentLocation"] as! [String : Double])
                                            
                                            expectation.fulfill()
                                        }
                                }
                            }
                        }
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
    }
    
    func testGetSubgroupDocument() {
        let expectation = XCTestExpectation(description: "get data from db and test document")
        db.collection("convoys").whereField("name", isEqualTo: "adventure").getDocuments() { snapshot, err in
            if let error = err {
                XCTFail(error.localizedDescription)
            } else {
                let doc = FirebaseDataStoreDocument(document: snapshot!.documents.first!)
                
                let condition = DataStoreCondition(field: MemberFields.userUID, op: FirebaseOperator.isEqualTo, value: "2356")
                doc.getSubgroupDocument(ofType: .members, withConditions: [condition]) { result in
                    switch result {
                    case .failure(let e):
                        XCTFail(e.localizedDescription)
                        return
                    case .success(let docs):
                        XCTAssertEqual(docs.count, 1)
                        expectation.fulfill()
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testAddSubgroupDocument() {
        
        let expectation = XCTestExpectation(description: "get data from db and test document")
        db.collection("convoys").whereField("name", isEqualTo: "adventure").getDocuments() { snapshot, err in
            if let error = err {
                XCTFail(error.localizedDescription)
            } else {
                XCTAssertEqual(snapshot!.documents.count, 1)
                let doc = FirebaseDataStoreDocument(document: snapshot!.documents.first!)
                
                let data: [String : Any] = [
                    "userUID" : "3",
                    "status" : "requested"
                ]
                
                doc.addSubgroupDocument(to: .members, newData: data) { [weak self] error in
                    if let e = error {
                        XCTFail(e.localizedDescription)
                    } else {
                        self?.db.collection("convoys").document(doc.id).collection("members").whereField("userUID", isEqualTo: "3")
                            .getDocuments() { snapshot, error2 in
                                if let err2 = error2 {
                                    XCTFail(err2.localizedDescription)
                                } else {
                                    XCTAssertEqual(snapshot!.documents.count, 1)
                                    expectation.fulfill()
                                }
                        }
                    }
                }
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
