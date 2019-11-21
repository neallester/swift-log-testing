import Foundation
import Logging

struct TestingLogHandler: LogHandler {

    init (label: String) {
        let internals = TestLogMessages.newHandlerInternals(forLabel: label)
        self.messagesContainer = internals.container
        self.logLevel = internals.logLevel
    }

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt) {
        var mergedMetadata = self.metadata
        var mergeConflict = false
        if let metadata = metadata {
            mergedMetadata.merge(metadata, uniquingKeysWith: {(left, _) in
                mergeConflict = true
                return left
            })
        }
        var finalMetadata: Logger.Metadata?
        if mergeConflict {
            var conflictedKeys: [String] = []
            if let metadata = metadata {
                for key in metadata.keys {
                    if let _ = self.metadata[key] {
                        conflictedKeys.append(key)
                    }
                }
            }
            finalMetadata = [ "METADATA_KEY_CONFLICT": "\(conflictedKeys.sorted().joined(separator: ","))"] // Sort to ensure order is determinisitic
        } else if !mergedMetadata.isEmpty {
            finalMetadata = mergedMetadata
        }
        let newMessage =
            LogMessage(
                level: level,
                message: message,
                metadata: finalMetadata,
                file: file,
                function: function,
                line: line
            )
        self.messagesContainer.append(newMessage)
    }

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set(newValue) {
            self.metadata[metadataKey] = newValue
        }
    }

    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .info
    private var messagesContainer: TestLogMessages.Container
}

public struct LogMessage {

    let level: Logger.Level
    let message: Logger.Message
    let metadata: Logger.Metadata?
    let file: String
    let function: String
    let line: UInt

    public func toString(formatter: (_ level: Logger.Level,
                                     _ message: Logger.Message,
                                     _ metadata: Logger.Metadata?,
                                     _ file: String,
                                     _ function: String,
                                     _ line: UInt) -> String = LogMessage.defaultFormat)
    -> String {
        formatter(self.level,
                   self.message,
                   self.metadata,
                   self.file,
                   self.function,
                   self.line
        )
    }

    public static func defaultFormat (
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt)
    -> String {
        "\(level) \(message)\(metadataAsString(metadata))|\(URL(fileURLWithPath: file).lastPathComponent)|\(function)"
    }

    public static func metadataAsString (_ metadata: Logger.Metadata?,
                                         prefix: String = "|",
                                         keyValueSeparator: String = "=",
                                         metadataSeparator: String = ";")
    -> String {
        var result = ""
        if let metadata = metadata, !metadata.isEmpty {
            result = "\(prefix)\(metadataStrings(separator: keyValueSeparator, metadata: metadata).joined(separator: metadataSeparator))"
        }
        return result
    }

    public static func metadataStrings (separator: String = "=",
                                        metadata: Logger.Metadata)
    -> [String] {
        metadata.map { (key, value) in
            "\(key)\(separator)\(value)"
        }.sorted() // Sort to ensure order is deterministic (default order for Dictionary values varies by platform)
    }
}

public enum TestLogMessages {

    /**
        Prepare the logging system to record log messages for use in tests.
     
        Calls to this function may placed within setUp() and/or the body of tests. It is safe to call
        this method multiple times during execution of test sets. However, calling LoggingSystem.bootstrap()
        directly before or after calling this function will produce undefined behavior, most likely a crash.
    */
    public static func bootstrap() {
        queue.sync {
            if (!isInitialized) {
                isInitialized = true
                LoggingSystem.bootstrap(TestingLogHandler.init)
            }
        }
    }

    /**
        Note: LoggMessages.bootstrap() must be called in order to configure the logging system to write to these
              containers.
     
        - parameter forLabel: The label associated with the Logger for which messages were recorded.
     
        - returns: The LogMessages.Container containing all messages logged to Loggers created with **forLabel**.
    */
    public static func container (forLabel: String) -> Container {
        var result: Container?
        queue.sync {
            result = _container(forLabel: forLabel)
        }
        return result!
    }
    
    static func newHandlerInternals (forLabel: String) -> (container: Container, logLevel: Logger.Level) {
        var container: Container?
        var logLevel: Logger.Level?
        queue.sync {
            container = _container(forLabel: forLabel)
            logLevel = _logLevels[forLabel] ?? TestLogMessages.defaultLevel
        }
        return (container: container!, logLevel: logLevel!)
    }
    
    // Not thread safe, must be called on queue
    private static func _container (forLabel: String) -> Container {
        if let container = _containers[forLabel] {
            return container
        } else {
            let newContainer = Container(label: forLabel)
            _containers[forLabel] = newContainer
            return newContainer
        }
    }
    
    
    /**
            Sets the Logger.Level for any newly created Logger instances for the given label. Does not affect the behavior
            of existing loggers.

        - parameter logLevel: The Logger.Level to apply to newly created loggers (messages with priority
                              below this level will not added to the message container).

        - parameter forLabel: The label for which LogLevel should be set.
     
    */
    public static func set (logLevel: Logger.Level, forLabel: String) {
        queue.async {
            _logLevels[forLabel] = logLevel
        }
    }
    
    /**
        - parameter forLabel: The label for which Logger.Level is requested
     
        - returns: The Logger.Level to apply to newly created loggers associated with **forLabel** (messages with priority
                   below this level will not added to the message container).
    */
    public static func logLevel (forLabel: String) -> Logger.Level {
        var result = TestLogMessages.defaultLevel
        queue.sync {
            if let level = _logLevels[forLabel] {
                result = level
            }
        }
        return result

    }
    
    public static let defaultLevel = Logger.Level.info

    public class Container {

        init (label: String) {
            self.label = label
            self.queue = DispatchQueue(label: "LogMessages.Container:\(label)")
        }

        public let label: String

        /**
            - returns: All messages which have been received on loggers associated with **label**
         */
        public var messages: [LogMessage] {
            get {
                var result: [LogMessage] = []
                queue.sync {
                    result = self._messages
                }
                return result
            }
        }

        /**
            Wiipe out all currently stored messages.
         */
        public func reset() {
            queue.sync {
                self._messages = []
            }
        }
        
        /**
            print all log entries to console
         
            - parameter formatter: enables customization of output format
         */
        public func print (formatter: (_ level: Logger.Level,
                                       _ message: Logger.Message,
                                       _ metadata: Logger.Metadata?,
                                       _ file: String,
                                       _ function: String,
                                       _ line: UInt)
                           -> String = LogMessage.defaultFormat)
        {
            queue.sync {
                for entry in _messages {
                    Swift.print (entry.toString(formatter: formatter))
                }
            }
        }

        internal func append (_ newMessage: LogMessage) {
            queue.sync {
                self._messages.append(newMessage)
            }
        }

        private var _messages: [LogMessage] = []
        private let queue: DispatchQueue
    }

    private static var _containers: [ String: Container ] = [:]
    private static var _logLevels: [ String : Logger.Level] = [:]
    private static let queue = DispatchQueue(label: "LogMessages")
    private static var isInitialized = false

}
