//
//  ConvoyModelTests.swift
//  ConvoyTests
//
//  Created by Jack Adams on 09/05/2020.
//  Copyright © 2020 Jack Adams. All rights reserved.
//

import XCTest
@testable import Convoy


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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    

}

class MockUpdateUserMembershipModel: ConvoyModel {
    public var input = [String : Any]()
    
    override func updateUserMembership(for convoy: Convoy, withData data: [String : Any]) {
        input["convoy"] = convoy.convoyID
        input["data"] = data
    }
}

