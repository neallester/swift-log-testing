import Dispatch
import Logging

struct TestingLogHandler: LogHandler {
    
    init (label: String) {
        messagesContainer = LogMessages.container (forLabel: label)
    }
    
    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt)
    {
        var metadataStrings: [String] = []
        metadataStrings = self.metadata.map { (key, value) in
            "\(key)=\(value)"
        }
        if let metadata = metadata {
            metadataStrings.append(contentsOf: metadata.map { (key, value) in
                "\(key)=\(value)"
            })
        }
        let metadataString = metadataStrings.sorted().joined(separator: ";")
        // Sort to ensure order is deterministic
        let newMessage =
            LogMessage (
                level: level,
                message: message,
                metadata: metadataString,
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
    private var messagesContainer: LogMessages.Container
}

public struct LogMessage {
    
    let level: Logger.Level
    let message: Logger.Message
    let metadata: String
    let file: String
    let function: String
    let line: UInt
    
    func toFullString() -> String {
        var metadataString = ""
        if !metadata.isEmpty {
            metadataString = "\(metadata)|"
        }
        return "\(level) \(message)|\(metadataString)\(file)|\(function)" // Omit line number since that will produce generally
                                                                          // spurious false positives
    }
    
    func toString() -> String {
        var metadataString = ""
        if !metadata.isEmpty {
            metadataString = "|\(metadata)"
        }
        return "\(level) \(message)\(metadataString)" // Omit line number since that will produce generally
                                                       // spurious false positives
    }

}


enum LogMessages {
    
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
        var result: Container? = nil
        queue.sync {
            if let container = _containers[forLabel] {
                result = container
            } else {
                let newContainer = Container (label: forLabel)
                _containers[forLabel] = newContainer
                result = newContainer
            }
        }
        return result!
    }

    
    class Container {
        
        init (label: String) {
            self.label = label
            self.queue = DispatchQueue (label: "LogMessages.Container:\(label)")
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
        
        internal func append (_ newMessage: LogMessage) {
            queue.sync {
                self._messages.append (newMessage)
            }
        }
        
        private var _messages: [LogMessage] = []
        
        private let queue: DispatchQueue
        
    }
        
    private static var _containers: [ String : Container ] = [:]
    
    private static let queue = DispatchQueue(label: "LogMessages")
    
    private static var isInitialized = false
    
}

