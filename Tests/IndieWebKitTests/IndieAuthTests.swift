import XCTest
@testable import IndieWebKit

final class IndieAuthTests: XCTestCase {
    
    func testValidProfileUrls() {
        let valid_profile_1 = "https://example.com/"
        let valid_profile_2 = "https://example.com/username"
        let valid_profile_3 = "https://example.com/users?id=100"
        let valid_profile_4 = "http://127.0.0.1/";
        let valid_profile_5 = "http://[::1]/";


        XCTAssertEqual(IndieAuth.checkForValidProfile(valid_profile_1), true)
        XCTAssertEqual(IndieAuth.checkForValidProfile(valid_profile_2), true)
        XCTAssertEqual(IndieAuth.checkForValidProfile(valid_profile_3), true)
        XCTAssertEqual(IndieAuth.checkForValidProfile(valid_profile_4), true)
        XCTAssertEqual(IndieAuth.checkForValidProfile(valid_profile_5), true)
    }

    func testInvalidProfileUrls() {
        let invalid_profile_1 = "example.com" // missing scheme
        let invalid_profile_2 = "mailto:user@example.com" // invalid scheme
        let invalid_profile_3 = "https://example.com/foo/../bar" // contains a double-dot path
        let invalid_profile_4 = "https://example.com/#me" // contains a gragment
        let invalid_profile_5 = "https://user:pass@example.com/" // contains username and password
        let invalid_profile_6 = "https://172.28.92.51/" // host is an IPv4 address
        let invalid_profile_7 = "https://2001:0db8:85a3:0000:0000:8a2e:0370:7334/" // host is an IPv6 Address
        let invalid_profile_8 = "https://example.com/foo/./bar" // contains a single-dot path


        XCTAssertEqual(IndieAuth.checkForValidProfile(invalid_profile_1), false)
        XCTAssertEqual(IndieAuth.checkForValidProfile(invalid_profile_2), false)
        XCTAssertEqual(IndieAuth.checkForValidProfile(invalid_profile_3), false)
        XCTAssertEqual(IndieAuth.checkForValidProfile(invalid_profile_4), false)
        XCTAssertEqual(IndieAuth.checkForValidProfile(invalid_profile_5), false)
        XCTAssertEqual(IndieAuth.checkForValidProfile(invalid_profile_6), false)
        XCTAssertEqual(IndieAuth.checkForValidProfile(invalid_profile_7), false)
        XCTAssertEqual(IndieAuth.checkForValidProfile(invalid_profile_8), false)
    }
    
//    func testNormalizeHostnameUrl() {
//        let hostname = "example.com";
//
//        XCTAssertEqual(IndieAuth.normalizeProfileUrl(string: hostname), URL(string: "http://example.com/"))
//    }
    
    static var allTests = [
        ("Test Valid Profile Urls", testValidProfileUrls),
        ("Test Invalid Profile Urls", testInvalidProfileUrls),
//        ("Test Normalized Profile Urls", testNormalizeHostnameUrl),
    ]
}
