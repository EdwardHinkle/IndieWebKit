import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(IndieWebKitTests.allTests),
    ]
}
#endif
