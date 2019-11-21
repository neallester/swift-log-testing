//
//  ExampleTests.swift
//  
//
//  Created by Neal Lester on 11/20/19.
//

import XCTest
import Logging
import SwiftLogTesting

final class ExampleTests: XCTestCase {
    
    struct StructUnderTest {
        
        static let loggingLabel = "SwiftLogTesting.StructUnderTest"
        
        var myVar: Int = 0 {
            didSet (oldValue) {
                let logger = Logger (label: StructUnderTest.loggingLabel)
                logger.info("StructUnderTest.myVar.didset", metadata: ["oldValue" : "\(oldValue)", "newValue" : "\(myVar)"])
            }
        }
        
    }
    
    override func setUp() {
        TestLogMessages.bootstrap()         // Must be called before logging or obtaining a TestLogMessages.Container
        
                                            // It is safe to call bootstrap() multiple times in a single execution
        
                                            // Do not call LoggingSystem.bootstrap() before or after calling
                                            // TestLogMessages.bootstrap()
    }
    
    public func testStructUnderTest() {
        TestLogMessages.bootstrap()         // May also safely be called in on or more test bodies
        
        let container = TestLogMessages.container(forLabel: StructUnderTest.loggingLabel)
        container.reset()                   // Wipes out any existing messages
        
                                            // All loggers created with the same label during a single execution
                                            // share the same TestLogMessages.Container. The TestingLogHandler and
                                            // TestLogMessages.Container are thread safe, but tests run in parallel
                                            // using loggers created against the same label may produce log entries
                                            // in a non-deterministic order.
        var myStruct = StructUnderTest()
        XCTAssertEqual (0, myStruct.myVar)
        myStruct.myVar = 20
        XCTAssertEqual (20, myStruct.myVar)
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info StructUnderTest.myVar.didset|newValue=20;oldValue=0|ExampleTests.swift|myVar", container.messages[0].toString())
                                            // Use toString (formatter:) to specify message format
        
        container.reset()
        container.print()                   // prints all log messages to the console
                                            // use formatter: argument if custom format is required
    }

}

