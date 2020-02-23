import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(lastfm_swiftTests.allTests),
    ]
}
#endif
