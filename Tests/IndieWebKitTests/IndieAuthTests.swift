import XCTest
@testable import IndieWebKit

final class IndieAuthTests: XCTestCase {
    func verifyValidProfileUrls() {
        let valid_profile_1 = "https://example.com/"
        let valid_profile_2 = "https://example.com/username"
        let valid_profile_3 = "https://example.com/users?id=100"
    
    
        XCTAssertEqual(IndieAuth.isValidProfile(string: valid_profile_1), true)
        XCTAssertEqual(IndieAuth.isValidProfile(string: valid_profile_2), true)
        XCTAssertEqual(IndieAuth.isValidProfile(string: valid_profile_3), true)
    }
    
    func verifyInvalidProfileUrls() {
        let invalid_profile_1 = "example.com"
        let invalid_profile_2 = "mailto:user@example.com"
        let invalid_profile_3 = "https://example.com/foo/../bar"
        let invalid_profile_4 = "https://example.com/#me"
        let invalid_profile_5 = "https://user:pass@example.com/"
        let invalid_profile_6 = "https://172.28.92.51/"
        
        
        XCTAssertEqual(IndieAuth.isValidProfile(string: invalid_profile_1), false)
        XCTAssertEqual(IndieAuth.isValidProfile(string: invalid_profile_2), false)
        XCTAssertEqual(IndieAuth.isValidProfile(string: invalid_profile_3), false)
        XCTAssertEqual(IndieAuth.isValidProfile(string: invalid_profile_4), false)
        XCTAssertEqual(IndieAuth.isValidProfile(string: invalid_profile_5), false)
        XCTAssertEqual(IndieAuth.isValidProfile(string: invalid_profile_6), false)
    }
    
    static var allTests = [
        ("verifyValidProfileUrls", verifyValidProfileUrls),
        ("verifyInvalidProfileUrls", verifyInvalidProfileUrls),
    ]
}
