//
//  UserModelTests.swift
//  ConvoyTests
//
//  Created by Jack Adams on 12/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import XCTest
@testable import Convoy

class UserModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSendFriendRequest() {
        let model = UserModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        let auth = MockAuthService()
        model.authService = auth
        
        let user = User(displayName: "test", email: "test@me.com", userUID: "4577889")
        
        model.sendFriendRequest(to: user)
        
        if let request = dataStore.input["friendRequest"] as? [String : Any] {
            let sender = request["sender"]
            let receiver = request["receiver"]
            let status = request["status"]
            
            XCTAssertEqual(sender! as! String, auth.currentUser!.userUID)
            XCTAssertEqual(receiver! as! String, user.userUID)
            XCTAssertEqual(status! as! String, "sent")
        }
    }
    
    func testGetAllUsers() {
        let model = UserModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        let auth = MockAuthService()
        model.authService = auth
        
        dataStore.userStore = ["1" : User(displayName: "mike", email: "mike@me.com", userUID: "1"), "2": User(displayName: "kevin", email: "kevin@me.com", userUID: "2")]
        
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        
        model.getAllUsers() {result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, dataStore.userStore.values.count)
                XCTAssertEqual(users, Array(dataStore.userStore.values))
                
                expectation.fulfill()
            case .failure(let err):
                XCTFail(err.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testSearchAllUsers() {
        let model = MockUserModel()
        let search = "mi"
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        model.searchAllUsers(for: search) {result in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let users):
                XCTAssertEqual(users, model.storedUsers)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testUpdateFriendRequestStatus() {
        
        let model = UserModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        let auth = MockAuthService()
        model.authService = auth
        
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        let senderID = "8697"
        let newStatus = "trast"
        
        //test with invalid statuses, ids etc
        model.updateFriendRequestStatus(to:newStatus, for: senderID) {
            if let update = dataStore.input["friendRequestUpdate"] as? [String : String] {
                
                XCTAssertEqual(update["sender"], senderID)
                XCTAssertEqual(update["receiver"], auth.currentUser?.userUID)
                XCTAssertEqual(update["status"], newStatus)
                expectation.fulfill()
            }
            
            
            
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testGetFriendRequests() {
        
        let model = UserModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        let auth = MockAuthService()
        model.authService = auth
        
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        
        model.getFriendRequests() { result in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let users):
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users.first!, dataStore.userStore["2"]!)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testGetFriends() {
        
        let model = UserModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        let auth = MockAuthService()
        model.authService = auth
        
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        
        model.getFriends() { result in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let users):
                
                XCTAssertEqual(users, Array(dataStore.userStore.values))
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testGetUser() {
        let model = UserModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        
        model.getUser(withID: "1") { result in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let user):
                
                XCTAssertEqual(user, dataStore.userStore["1"]!)
                expectation.fulfill()
                
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
}

class MockUserModel : UserModel {
    
    var storedUsers = [User(displayName: "mike", email: "mike@me.com", userUID: "1"), User(displayName: "mike", email: "mike@me.com", userUID: "1")]
    
    override func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        completion(.success(storedUsers))
    }

    
}
