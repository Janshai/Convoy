//
//  ConvoyModelTests.swift
//  ConvoyTests
//
//  Created by Jack Adams on 09/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import XCTest
@testable import Convoy
import CoreLocation


class ConvoyModelTests: XCTestCase {

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
    

    
    func testCreateConvoy() {
        let model = ConvoyModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        
        
        let friends = ["1", "2"]
        let destination = ["long" : 4.6075, "lat" : 670504.354]
        
        let start = ["long" : 6.6075, "lat" : 504.354]
        let data: [String : Any] = [
            "name" : "hertyui",
            "destination": destination,
            "destinationPlaceName": " glasgow",
            "friends": friends,
            "start": start,
            "startLocationPlaceName": "manchester"
            
        ]
        
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        model.createConvoy(from: data) { error in
            if error != nil {
                XCTFail(error!.localizedDescription)
            } else {
                //test convoy exists
                let index = dataStore.convoyStore.first() { pair in
                    if pair.value.name == data["name"] as! String {
                        return true
                    } else {
                        return false
                    }
                }
                
                XCTAssertNotNil(index)
                //test members exist
                
                
                let members = Array(MockDataStoreDocument.memberStoreState.values)
                for friend in friends {
                    XCTAssert(members.contains() { member in
                        return member.userUID == friend
                    }, "no member creted for \(friend)")
                }
                
                
                expectation.fulfill()
            }
            
        
        }
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    
    
    func testDeclineInvite() throws {
        let model = MockUpdateUserMembershipModel()
        let id = "testConvoy"
        let convoy = Convoy(id: id, name: "p", destination: [String : Double](), destinationPlaceName: "e")
        let data = ["status" : "declined"]
        model.declineInvite(to: convoy)
        
        XCTAssertEqual(try XCTUnwrap(model.input["convoy"] as? String) , id)
        if let storedData = model.input["data"] as? [String : String] {
            
            XCTAssertEqual(storedData, data)
        }
        
    }
    
    func testAcceptEvent() {
        let model = MockUpdateUserMembershipModel()
        let id = "testConvoy"
        let convoy = Convoy(id: id, name: "p", destination: [String : Double](), destinationPlaceName: "e")
        let data: [String : Any] = ["start" : ["lat" : 45.0987, "long" : 2.4959483], "startLocationPlaceName" : "a place"]
        let outData: [String : Any] = ["status" : "not started", "start" : ["lat" : 45.0987, "long" : 2.4959483], "startLocationPlaceName" : "a place"]
        
        model.acceptInvite(to: convoy, withStartLocation: data)
        
        XCTAssertEqual(try XCTUnwrap(model.input["convoy"] as? String) , id)
        if let storedData = model.input["data"] as? [String : Any] {
            
            if let start : [String : Double] = storedData["start"] as? [String : Double] {
                let startOut: [String: Double] = outData["start"] as! [String : Double]
                XCTAssertEqual(try XCTUnwrap(start["long"]), startOut["long"]!)
                XCTAssertEqual(try XCTUnwrap(start["lat"]), startOut["lat"]!)
                
            }
            
            XCTAssertEqual(try XCTUnwrap(storedData["startLocationPlaceName"] as? String), outData["startLocationPlaceName"] as! String)
            
            XCTAssertEqual(storedData["status"] as! String, outData["status"] as! String)
            
        }
    }
    
    func testArrived() throws {
        let model = MockUpdateUserMembershipModel()
        let id = "testConvoy"
        let convoy = Convoy(id: id, name: "p", destination: [String : Double](), destinationPlaceName: "e")
        let data = ["status" : "arrived"]
        model.arrived(convoy: convoy)
        
        XCTAssertEqual(try XCTUnwrap(model.input["convoy"] as? String) , id)
        if let storedData = model.input["data"] as? [String : String] {
            
            XCTAssertEqual(storedData, data)
        }
        
    }
    
    func testUpdateCurrentLocation() throws {
        let model = MockUpdateUserMembershipModel()
        let id = "testConvoy"
        let convoy = Convoy(id: id, name: "p", destination: [String : Double](), destinationPlaceName: "e")
        let location = CLLocation(latitude:  53.417470, longitude: -2.118180)
        model.updateCurrentLocation(to: location, for: convoy)
        
        XCTAssertEqual(try XCTUnwrap(model.input["convoy"] as? String) , id)
        if let storedData = model.input["data"] as? [String : Double] {
            
            XCTAssertEqual(storedData["lat"], location.coordinate.latitude)
            XCTAssertEqual(storedData["long"], location.coordinate.longitude)
        }
        
    }
    
    func testCommence() {
        
        
        let model = MockUpdateUserMembershipModel()
        let id = "testConvoy"
        let convoy = MockConvoy(id: id, name: "p", destination: [String : Double](), destinationPlaceName: "e")
        let location = CLLocation(latitude:  53.417470, longitude: -2.118180)
        convoy.members = []
        convoy.members?.append(ConvoyMember(id: "1" , status: "not started"))
        
        convoy.members?.first?.start = ["long" : location.coordinate.longitude, "lat" : location.coordinate.latitude]
        
        model.commence(convoy: convoy)
        
        XCTAssertEqual(try XCTUnwrap(model.input["convoy"] as? String) , id)

        
        if let storedData = model.input["data"] as? [String : Any] {
            let data: [String:Any] = [
                "status" : "in progress",
                "currentLocation" : convoy.members!.first!.start!
            ]
            
            XCTAssertEqual(try XCTUnwrap(storedData["status"] as? String), data["status"] as! String)
            XCTAssertEqual(try XCTUnwrap(storedData["currentLocation"] as? [String: Double]), data["currentLocation"] as! [String : Double])
            
            
        }
    }
    
    func testUpdateRoute() throws {
        let model = MockUpdateUserMembershipModel()
        let id = "testConvoy"
        let convoy = Convoy(id: id, name: "p", destination: [String : Double](), destinationPlaceName: "e")
        let location = CLLocation(latitude:  53.417470, longitude: -2.118180)
        model.updateRoute(to: [location], for: convoy)
        
        XCTAssertEqual(try XCTUnwrap(model.input["convoy"] as? String) , id)
        if let storedData = model.input["data"] as? [String : Any] {
            
            if let route = storedData["route"] as? [[String: Double]] {
                XCTAssertEqual(route[0]["long"], location.coordinate.longitude)
                XCTAssertEqual(route[0]["lat"], location.coordinate.latitude)
                
            }
            
            
        }
        
    }
    
    
    func testGetConvoy() {
        let model = ConvoyModel()
        model.dataStore = DataStoreMock()
        let id = "1"
        model.getConvoy(withID: id) { result in
            switch result {
            case .success(let convoy):
                XCTAssertEqual(convoy.convoyID!, id)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
        }
    }
    
    func testGetConvoyWithEmptyDataStore() {
        let model = ConvoyModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        dataStore.convoyStore.removeAll()
        let id = "1"
        model.getConvoy(withID: id) { result in
            switch result {
            case .success(_):
                XCTFail()
            case .failure(_):
                XCTAssert(true)
            }
            
        }
    }
    
    func testGetConvoyCallbackCalled() {
        let model = ConvoyModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        // 1. Define an expectation
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")

        // 2. Exercise the asynchronous code
        model.getConvoy(withID: "1") { result in
          // Don't forget to fulfill the expectation in the async callback
          expectation.fulfill()
        }

        // 3. Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetConvoyCallbackCalledEmptyDataStore() {let model = ConvoyModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        dataStore.convoyStore.removeAll()
        // 1. Define an expectation
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")

        // 2. Exercise the asynchronous code
        model.getConvoy(withID: "1") { result in
          // Don't forget to fulfill the expectation in the async callback
            switch result {
            case .failure(_):
                expectation.fulfill()
            default:
                return
            }
          
        }

        // 3. Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 1.0)
    }
    func testUpdateMembers() throws {
        let model = ConvoyModel()
        let dataStore = DataStoreMock()
        dataStore.addMembers()
        model.dataStore = dataStore
         let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        model.updateMembers(for: dataStore.convoyStore["1"]!) { convoy in
            XCTAssertEqual(convoy.members?.count, 2)
            if let mems = convoy.members {
                let m1 = mems[0]
                let m2 = mems[1]
                XCTAssertEqual(m1.userUID, "2356")
                XCTAssertEqual(m1.status, "not started")
                XCTAssertEqual(m2.userUID, "34")
                XCTAssertEqual(m2.status, "requested")
                expectation.fulfill()
                
            }
        
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateMembersNoMembers() {
        let model = ConvoyModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        
        model.updateMembers(for: dataStore.convoyStore["1"]!) { convoy in
            XCTAssertEqual(convoy.members?.count, 0)
        }
    }
    
    func testGetConvoyInvites() {
        let model = ConvoyModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        UserModel.shared.authService = MockAuthService()
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        model.getConvoyInvites() { result in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let convoys):
                XCTAssertEqual(convoys.count, 1)
                XCTAssertEqual(convoys[0].convoyID!, dataStore.convoyStore["2"]?.convoyID!)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetConvoys() {
        let model = ConvoyModel()
        let dataStore = DataStoreMock()
        model.dataStore = dataStore
        UserModel.shared.authService = MockAuthService()
        let expectation = XCTestExpectation(description: "model does stuff and runs the callback closure")
        
        dataStore.addMembers()
        
        model.getConvoys() { result in
            switch result {
            case .failure(let err):
                XCTFail(err.localizedDescription)
            case .success(let convoys):
                XCTAssertEqual(convoys.count, 1)
                let convoy = convoys.first!
                XCTAssertEqual(convoy.convoyID!, "1")
                XCTAssertEqual(convoy.members?.count, 2)
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
class MockConvoy: Convoy {
    override var userMember: ConvoyMember? {
        return members?.first
    }
}

class MockUpdateUserMembershipModel: ConvoyModel {
    public var input = [String : Any]()
    
    override func updateUserMembership(for convoy: Convoy, withData data: [String : Any]) {
        input["convoy"] = convoy.convoyID
        input["data"] = data
    }
}



