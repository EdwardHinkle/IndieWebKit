import XCTest
@testable import IndieWebKit

final class MicropubTests: XCTestCase {
    
    let micropubEndpoint = URL(string: "https://micropub.rocks/client/HTSxBUnl2jHeMh1Y/micropub")!
    let accessToken = "80ntMvtkk7LfoJGUJraX5bUrNjbJn1AXKZLaW9zebcSrAyyPKcGjNpY3DfL0q2XoaKNhpTtoUzEQoYiaSaJSCZS0V0OFHhVQF1VJo6ngzd2mK2MwKLahsdkqGDIwN9xr"
    
    // Micropub.rocks 100 - Create an h-entry post (form-encoded)
    func testCreateFormEncodedHEntryPost() {
        XCTAssertTrue(false)
    }
    
    static var allTests = [
        ("Create form encoded h-entry post", testCreateFormEncodedHEntryPost),
    ]
}
