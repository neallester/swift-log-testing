# swift-log-testing
Logs are first class system outputs; system administrators often depend on their reliability in production.
Test Swift applications and libraries to ensure they emit the expected log entries.
This Swift package provides a
[swift-log](https://github.com/apple/swift-log) [LogHandler](https://github.com/apple/swift-log/blob/master/Sources/Logging/LogHandler.swift)
for use during application testing.

To declare the dependency in `Package.swift`:
```swift
.package(url: "https://github.com/neallester/swift-log-testing.git", from: "0.0.0"),
```
then (typically) add the dependency to the testing target:
```swift
.testTarget(name: "YourAppNameTests", dependencies: ["SwiftLogTesting"]),
```

See the [example](https://github.com/neallester/swift-log-testing/blob/master/Tests/SwiftLogTestingTests/ExampleTests.swift) for details on how to use swift-log-testing
in tests.
## Status
This package is currently **beta**. Breaking changes will be indicated by incrementing the MINOR version number (0.X)
until the 1.0 major version is released.
