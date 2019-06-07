import XCTest
@testable import IndieWebKit

final class IndieWebKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(IndieWebKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
