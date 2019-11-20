import XCTest
import Logging
@testable import SwiftLogTesting



final class TestingLogHandlerTests: XCTestCase {

    func testLogMessageToString() {
        var message = LogMessage(level: .critical, message: "Message1", metadata: "", file: "file", function: "function", line: 20)
        XCTAssertEqual ("critical Message1|file|function", message.toFullString())
        message = LogMessage(level: .critical, message: "Message1", metadata: "key1=value1", file: "file", function: "function", line: 20)
        XCTAssertEqual ("critical Message1|key1=value1|file|function", message.toFullString())
    }
    
    func testLogging() {
        LogMessages.bootstrap()
        let testingLabel = "github.com/neallester/TestingLogHandlerTests"
        let logger = Logger (label: testingLabel)
        let container = LogMessages.container(forLabel: testingLabel)
        XCTAssertEqual (0, container.messages.count)
        logger.log(level: .info, "My Message 1")
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info My Message 1", container.messages[0].toString())
        XCTAssertEqual ("info My Message 1|/Users/neal/xcode/swift-log-testing/Tests/SwiftLogTestingTests/TestingLogHandlerTests.swift|testLogging()", container.messages[0].toFullString())
        container.reset()
        XCTAssertEqual (0, container.messages.count)
        logger.log(level: .info, "My Message 2", metadata: ["key1" : "value1"])
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info My Message 2|key1=value1", container.messages[0].toString())
        XCTAssertEqual ("info My Message 2|key1=value1|/Users/neal/xcode/swift-log-testing/Tests/SwiftLogTestingTests/TestingLogHandlerTests.swift|testLogging()", container.messages[0].toFullString())
        logger.log(level: .info, "My Message 3", metadata: ["key1" : "value1", "key2" : "value2"])
        XCTAssertEqual (2, container.messages.count)
        XCTAssertEqual ("info My Message 3|key1=value1;key2=value2", container.messages[1].toString())
        XCTAssertEqual ("info My Message 3|key1=value1;key2=value2|/Users/neal/xcode/swift-log-testing/Tests/SwiftLogTestingTests/TestingLogHandlerTests.swift|testLogging()", container.messages[1].toFullString())
    }

}


