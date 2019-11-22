import XCTest
import Logging
@testable import SwiftLogTesting



final class TestingLogHandlerTests: XCTestCase {

    func customFormatter (level: Logger.Level,
                          message: Logger.Message,
                          metadata: Logger.Metadata?,
                          file: String,
                          function: String,
                          line: UInt)
    -> String
    {
        "\(message)"
    }

    func testLogMessageToString() {
                
        var message = LogMessage(level: .info, message: "Message1", metadata: nil, file: "/directory/subdirectory/file.swift", function: "function()", line: 20)
        XCTAssertEqual ("info Message1|file.swift|function()", message.toString())
        XCTAssertEqual ("Message1", message.toString(formatter: customFormatter))
        message = LogMessage(level: .info, message: "Message1", metadata: ["key1" : "value1"], file: "/directory/subdirectory/file.swift", function: "function()", line: 20)
        XCTAssertEqual ("info Message1|key1=value1|file.swift|function()", message.toString())
        XCTAssertEqual ("Message1", message.toString(formatter: customFormatter))
        message = LogMessage(level: .info, message: "Message1", metadata: nil, file: "/directory/subdirectory/file.swift", function: "function()", line: 20)
        XCTAssertEqual ("info Message1|file.swift|function()", message.toString())
        XCTAssertEqual ("Message1", message.toString(formatter: customFormatter))
        message = LogMessage(level: .info, message: "Message1", metadata: ["key1" : "value1"], file: "/directory/subdirectory/file.swift", function: "function()", line: 20)
        XCTAssertEqual ("info Message1|key1=value1|file.swift|function()", message.toString())
        XCTAssertEqual ("Message1", message.toString(formatter: customFormatter))
    }
    
    func testLogMessagedefaultFormat() {
        XCTAssertEqual ("info M1|file|function", LogMessage.defaultFormat(level: .info, message: "M1", metadata: nil, file: "file", function: "function", line: 20))
        XCTAssertEqual ("info M1|file|function", LogMessage.defaultFormat(level: .info, message: "M1", metadata: [:], file: "file", function: "function", line: 20))
        XCTAssertEqual ("info M1|k1=v1|file|function", LogMessage.defaultFormat(level: .info, message: "M1", metadata: ["k1":"v1"], file: "file", function: "function", line: 20))
        XCTAssertEqual ("info M1|k1=v1;k2=v2|file|function", LogMessage.defaultFormat(level: .info, message: "M1", metadata: ["k1":"v1", "k2":"v2"], file: "file", function: "function", line: 20))
        XCTAssertEqual ("critical M1|file|function", LogMessage.defaultFormat(level: .critical, message: "M1", metadata: nil, file: "file", function: "function", line: 20))
        XCTAssertEqual ("critical M1|file|function", LogMessage.defaultFormat(level: .critical, message: "M1", metadata: [:], file: "file", function: "function", line: 20))
        XCTAssertEqual ("critical M1|k1=v1|file|function", LogMessage.defaultFormat(level: .critical, message: "M1", metadata: ["k1":"v1"], file: "file", function: "function", line: 20))
        XCTAssertEqual ("critical M1|k1=v1;k2=v2|file|function", LogMessage.defaultFormat(level: .critical, message: "M1", metadata: ["k1":"v1", "k2":"v2"], file: "file", function: "function", line: 20))
    }
    
    func testLogMessageMetadataStrings() {
        var result: [String] = LogMessage.metadataStrings(metadata: [:])
        XCTAssertEqual (0, result.count)
        result = LogMessage.metadataStrings(separator: "-", metadata: [:])
        XCTAssertEqual (0, result.count)
        result = LogMessage.metadataStrings(metadata: ["k1" : "v1"])
        XCTAssertEqual (1, result.count)
        XCTAssertEqual ("k1=v1", result[0])
        result = LogMessage.metadataStrings(separator: "=", metadata: ["k1" : "v1"])
        XCTAssertEqual (1, result.count)
        XCTAssertEqual ("k1=v1", result[0])
        result = LogMessage.metadataStrings(separator: "-", metadata: ["k1" : "v1"])
        XCTAssertEqual (1, result.count)
        XCTAssertEqual ("k1-v1", result[0])
        result = LogMessage.metadataStrings(metadata: ["k1" : "v1", "k2" : "v2"])
        XCTAssertEqual (2, result.count)
        XCTAssertEqual ("k1=v1", result[0])
        XCTAssertEqual ("k2=v2", result[1])
        result = LogMessage.metadataStrings(separator: "=", metadata: ["k1" : "v1", "k2" : "v2"])
        XCTAssertEqual (2, result.count)
        XCTAssertEqual ("k1=v1", result[0])
        XCTAssertEqual ("k2=v2", result[1])
        result = LogMessage.metadataStrings(separator: "-", metadata: ["k1" : "v1", "k2" : "v2"])
        XCTAssertEqual (2, result.count)
        XCTAssertEqual ("k1-v1", result[0])
        XCTAssertEqual ("k2-v2", result[1])
        result = LogMessage.metadataStrings(metadata: ["k2" : "v2", "k1" : "v1"])
        XCTAssertEqual (2, result.count)
        XCTAssertEqual ("k1=v1", result[0])
        XCTAssertEqual ("k2=v2", result[1])
        result = LogMessage.metadataStrings(separator: "=", metadata: ["k2" : "v2", "k1" : "v1"])
        XCTAssertEqual (2, result.count)
        XCTAssertEqual ("k1=v1", result[0])
        XCTAssertEqual ("k2=v2", result[1])
        result = LogMessage.metadataStrings(separator: "-", metadata: ["k2" : "v2", "k1" : "v1"])
        XCTAssertEqual (2, result.count)
        XCTAssertEqual ("k1-v1", result[0])
        XCTAssertEqual ("k2-v2", result[1])
    }
    
    func testLogMessageMetadataAsString() {
        XCTAssertEqual ("", LogMessage.metadataAsString(nil))
        XCTAssertEqual ("", LogMessage.metadataAsString([:]))
        XCTAssertEqual ("|k1=v1", LogMessage.metadataAsString(["k1" : "v1"]))
        XCTAssertEqual ("|k1=v1;k2=v2", LogMessage.metadataAsString(["k1" : "v1", "k2" : "v2"]))
        XCTAssertEqual ("|k1=v1;k2=v2", LogMessage.metadataAsString(["k2" : "v2", "k1" : "v1"]))
        XCTAssertEqual ("", LogMessage.metadataAsString(nil, prefix: ":", keyValueSeparator: "-", metadataSeparator: ","))
        XCTAssertEqual ("", LogMessage.metadataAsString([:], prefix: ":", keyValueSeparator: "-", metadataSeparator: ","))
        XCTAssertEqual (":k1-v1", LogMessage.metadataAsString(["k1" : "v1"], prefix: ":", keyValueSeparator: "-", metadataSeparator: ","))
        XCTAssertEqual (":k1-v1,k2-v2", LogMessage.metadataAsString(["k1" : "v1", "k2" : "v2"], prefix: ":", keyValueSeparator: "-", metadataSeparator: ","))
        XCTAssertEqual (":k1-v1,k2-v2", LogMessage.metadataAsString(["k2" : "v2", "k1" : "v1"], prefix: ":", keyValueSeparator: "-", metadataSeparator: ","))
    }

    func testLogging() {
        TestLogMessages.bootstrap()
        TestLogMessages.bootstrap()
        let testingLabel = "github.com/neallester/TestingLogHandlerTests.testLogging()"
        var logger = Logger (label: testingLabel)
        logger.logLevel = .trace
        let container = TestLogMessages.container(forLabel: testingLabel)
        XCTAssertEqual (0, container.messages.count)
        for level in Logger.Level.allCases {
            logger.log(level: level, "My Message 1")
            XCTAssertEqual (1, container.messages.count)
            XCTAssertEqual ("\(level) My Message 1|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
            container.reset()
        }
        logger.log(level: .info, "My Message 1")
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info My Message 1|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
        container.reset()
        logger.log(level: .info, "My Message 2", metadata: [:])
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info My Message 2|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
        container.reset()
        XCTAssertEqual (0, container.messages.count)
        logger.log(level: .info, "My Message 3", metadata: ["key1" : "value1"])
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info My Message 3|key1=value1|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
        logger.log(level: .info, "My Message 4", metadata: ["key1" : "value1", "key2" : "value2"])
        XCTAssertEqual (2, container.messages.count)
        XCTAssertEqual ("info My Message 4|key1=value1;key2=value2|TestingLogHandlerTests.swift|testLogging()", container.messages[1].toString())
        container.reset()
        logger.log(level: .info, "My Message 5", metadata: ["key2" : "value2", "key1" : "value1"])
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info My Message 5|key1=value1;key2=value2|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
        container.reset()
        logger[metadataKey: "key0"] = "value0"
        logger[metadataKey: "key3"] = "value3"
        logger.log(level: .info, "My Message 6")
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info My Message 6|key0=value0;key3=value3|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
        container.reset()
        logger.log(level: .info, "My Message 7", metadata: [:])
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info My Message 7|key0=value0;key3=value3|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
        container.reset()
        logger.log(level: .info, "My Message 8", metadata: ["key2" : "value2", "key1" : "value1"])
        XCTAssertEqual (1, container.messages.count)
        XCTAssertEqual ("info My Message 8|key0=value0;key1=value1;key2=value2;key3=value3|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
        logger[metadataKey: "key1"] = "conflictingKey"
        container.reset()
        logger.log(level: .info, "My Message 9", metadata: ["key2" : "value2", "key1" : "value1"])
        XCTAssertEqual ("info My Message 9|METADATA_KEY_CONFLICT=key1|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
        container.reset()
        logger.log(level: .info, "My Message 10", metadata: ["key2" : "value2", "key1" : "value1", "key0" : "value0"])
        XCTAssertEqual ("info My Message 10|METADATA_KEY_CONFLICT=key0,key1|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
        container.reset()
        logger[metadataKey: "key4"] = "value4"
        logger.log(level: .info, "My Message 11", metadata: ["key1" : "value1", "key2" : "value2", "key4" : "value4" ])
        XCTAssertEqual ("info My Message 11|METADATA_KEY_CONFLICT=key1,key4|TestingLogHandlerTests.swift|testLogging()", container.messages[0].toString())
    }
    
    func testSetLevel() {
        TestLogMessages.bootstrap()
        let testingLabel = "github.com/neallester/TestingLogHandlerTests.testSetLevel()"
        let logger1 = Logger (label: testingLabel)
        XCTAssertEqual (logger1.logLevel, TestLogMessages.defaultLevel)
        XCTAssertEqual (TestLogMessages.logLevel (forLabel: testingLabel), TestLogMessages.defaultLevel)
        TestLogMessages.set(logLevel: .critical, forLabel: testingLabel)
        XCTAssertEqual (TestLogMessages.logLevel (forLabel: testingLabel), Logger.Level.critical)
        let logger2 = Logger (label: testingLabel)
        XCTAssertEqual (logger1.logLevel, TestLogMessages.defaultLevel)
        XCTAssertEqual (logger2.logLevel, Logger.Level.critical)
    }
    
    func testContainerPrint() {
        TestLogMessages.bootstrap()
        let testingLabel = "github.com/neallester/TestingLogHandlerTests.testContainerPrint()"
        let logger = Logger (label: testingLabel)
        let container = TestLogMessages.container(forLabel: testingLabel)
        container.reset()
        logger.log(level: .info, "My Message 3", metadata: ["key1" : "value1"])
        logger.log(level: .info, "My Message 4", metadata: ["key1" : "value1", "key2" : "value2"])
        print ("Four lines of output should follow:")
        container.print()
        container.print (formatter: customFormatter)
    }
    
    func testMultiThreaded() {
        TestLogMessages.bootstrap()
        let queue = DispatchQueue (label: "testMultiThreaded", attributes: .concurrent)
        for _ in 0...200 {
            let repetitions = 200
            TestLogMessages.bootstrap()
            let group = DispatchGroup()
            let label1 = "TestingLogHandlerTests.testMultiThreaded1"
            let label2 = "TestingLogHandlerTests.testMultiThreaded2"
            let label3 = "TestingLogHandlerTests.testMultiThreaded3"
            let container1 = TestLogMessages.container(forLabel: label1)
            let container2 = TestLogMessages.container(forLabel: label2)
            let container3 = TestLogMessages.container(forLabel: label3)
            container1.reset()
            container2.reset()
            container3.reset()
            XCTAssertEqual (0, container1.messages.count)
            XCTAssertEqual (0, container2.messages.count)
            XCTAssertEqual (0, container3.messages.count)
            for _ in 1...repetitions {
                queue.async(group: group) {
                    XCTAssertTrue (container1.messages.count >= 0)
                    XCTAssertTrue (container2.messages.count >= 0)
                    XCTAssertTrue (container3.messages.count >= 0)
                }
            }
            let logger1 = Logger (label: label1)
            for _ in 1...repetitions {
                queue.async(group: group) {
                    logger1.log(level: .info, "L1M1")
                }
            }
            for _ in 1...repetitions {
                queue.async(group: group) {
                    logger1.log(level: .info, "L1M2", metadata: ["L1M2.KEY" : "Value"])
                }
            }
            for _ in 1...repetitions {
                queue.async(group: group) {
                    XCTAssertTrue (container1.messages.count >= 0)
                    XCTAssertTrue (container2.messages.count >= 0)
                    XCTAssertTrue (container3.messages.count >= 0)
                }
            }
            for _ in 1...repetitions {
                queue.async(group: group) {
                    TestLogMessages.set(logLevel: .debug, forLabel: label2)
                    let logger2 = Logger (label: label2)
                    logger2.log(level: .info, "L2M1")
                }
            }
            for _ in 1...repetitions {
                queue.async(group: group) {
                    let logger2 = Logger (label: label2)
                    TestLogMessages.set(logLevel: .info, forLabel: label2)
                    logger2.log(level: .info, "L2M2", metadata: ["L2M2.KEY" : "Value"])
                }
            }
            for _ in 1...repetitions {
                queue.async(group: group) {
                    XCTAssertTrue (container1.messages.count >= 0)
                    XCTAssertTrue (container2.messages.count >= 0)
                    XCTAssertTrue (container3.messages.count >= 0)
                }
            }
            for _ in 1...repetitions {
                queue.async(group: group) {
                    TestLogMessages.bootstrap()
                    let logger3 = Logger (label: label3)
                    logger3.log(level: .info, "L3M1")
                    logger3.log(level: .info, "L3M2", metadata: ["L3M2.KEY" : "Value"])
                }
            }
            for _ in 1...repetitions {
                queue.async(group: group) {
                    XCTAssertTrue (container1.messages.count >= 0)
                    XCTAssertTrue (container2.messages.count >= 0)
                    XCTAssertTrue (container3.messages.count >= 0)
                }
            }
            switch group.wait(timeout: DispatchTime.now() + 50.0) {
            case .timedOut:
                XCTFail("TimedOut")
            default:
                break
            }
            XCTAssertEqual (repetitions * 2, container1.messages.count)
            XCTAssertEqual (repetitions, container1.messages.filter { entry in entry.message.description.contains ("L1M1") }.count)
            XCTAssertEqual (repetitions, container1.messages.filter { entry in entry.message.description.contains ("L1M2") }.count)
            XCTAssertEqual (repetitions * 2, container2.messages.count)
            XCTAssertEqual (repetitions, container2.messages.filter { entry in entry.message.description.contains ("L2M1") }.count)
            XCTAssertEqual (repetitions, container2.messages.filter { entry in entry.message.description.contains ("L2M2") }.count)
            XCTAssertEqual (repetitions * 2, container3.messages.count)
            XCTAssertEqual (repetitions, container3.messages.filter { entry in entry.message.description.contains ("L3M1") }.count)
            XCTAssertEqual (repetitions, container3.messages.filter { entry in entry.message.description.contains ("L3M2") }.count)
        }
    }
}


