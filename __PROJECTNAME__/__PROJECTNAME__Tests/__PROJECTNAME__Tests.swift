//
//  _project_name_Tests.swift
//  __PROJECTNAME__Tests
//
//  Created by Pirush Prechathavanich on 3/8/18.
//  Copyright © 2018 Nimbl3. All rights reserved.
//

import XCTest
@testable import __PROJECTNAME___staging

class __PROJECTNAME__Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
                // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        #if PRODUCTION
            print("### production")
        #elseif STAGING
            print("### staging")
        #elseif TESTING
            print("### testing")
        #endif
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
