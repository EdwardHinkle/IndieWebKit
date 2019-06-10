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
    
    // TODO: Uncomment normalize hostname test when that function is build
//    func testNormalizeHostnameUrl() {
//        let hostnameOnly = "example.com"
//        let hostnameWithScheme = "https://example.com"
//        let hostnameWithPath = "example.com/"
//
//        XCTAssertEqual(IndieAuth.normalizeProfileUrl(hostnameOnly), URL(string: "http://example.com/"))
//        XCTAssertEqual(IndieAuth.normalizeProfileUrl(hostnameWithScheme), URL(string: "https://example.com/"))
//        XCTAssertEqual(IndieAuth.normalizeProfileUrl(hostnameWithPath), URL(string: "http://example.com/"))
//    }
    
    func testProfileDiscoveryRedirection() {
        let urlWithRedirect = URL(string: "https://aaronpk.com/")! // This url will redirect using a 301
        let urlWithoutRedirect = URL(string: "https://eddiehinkle.com/")! // This url should remain the same
        
        let expectationWithRedirect = self.expectation(description: "ProfileDiscoveryRequestWithRedirect")
        let discoveryWithRedirect = ProfileDiscoveryRequest(for: urlWithRedirect)
        discoveryWithRedirect.start {
            print("Check profile url after discovery request: \(discoveryWithRedirect.profile)")
            XCTAssertEqual(discoveryWithRedirect.profile, URL(string: "https://aaronparecki.com/")!)
            expectationWithRedirect.fulfill()
        }
        
        let expectationWithoutRedirect = self.expectation(description: "ProfileDiscoveryRequestWithoutRedirect")
        let discoveryWithoutRedirect = ProfileDiscoveryRequest(for: urlWithoutRedirect)
        discoveryWithoutRedirect.start {
            print("Check profile url after discovery request: \(discoveryWithoutRedirect.profile)")
            XCTAssertEqual(discoveryWithoutRedirect.profile, URL(string: "https://eddiehinkle.com/")!)
            expectationWithoutRedirect.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func testProfileDiscoveryEndpointsHTTPLink() {
        
        let profile = URL(string: "https://aaronpk.com")!
        let profileKnownEndpoints = [EndpointType.authorization_endpoint: URL(string: "https://aaronparecki.com/auth")!,
                                     EndpointType.token_endpoint: URL(string: "https://aaronparecki.com/auth/token")!,
                                     EndpointType.micropub: URL(string: "https://aaronparecki.com/micropub")!,
                                     EndpointType.microsub: URL(string: "https://aperture.p3k.io/microsub/1")!]
        let expectation = self.expectation(description: "ProfileDiscovyerEndpoints")
        let discovery = ProfileDiscoveryRequest(for: profile)
        discovery.start {
            XCTAssertEqual(discovery.endpoints[EndpointType.authorization_endpoint], profileKnownEndpoints[EndpointType.authorization_endpoint])
            XCTAssertEqual(discovery.endpoints[EndpointType.token_endpoint], profileKnownEndpoints[EndpointType.token_endpoint])
            XCTAssertEqual(discovery.endpoints[EndpointType.micropub], profileKnownEndpoints[EndpointType.micropub])
            XCTAssertEqual(discovery.endpoints[EndpointType.microsub], profileKnownEndpoints[EndpointType.microsub])
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testProfileDiscoveryEndpointsHTML() {
        
        let profile = URL(string: "https://eddiehinkle.com/")!
        let profileKnownEndpoints = [EndpointType.authorization_endpoint: URL(string: "https://eddiehinkle.com/auth")!,
                                     EndpointType.token_endpoint: URL(string: "https://eddiehinkle.com/auth/token")!,
                                     EndpointType.micropub: URL(string: "https://eddiehinkle.com/micropub")!,
                                     EndpointType.microsub: URL(string: "https://aperture.eddiehinkle.com/microsub/1")!,
                                     EndpointType.webmention: URL(string: "https://webmention.io/eddiehinkle.com/webmention")!]
        let expectation = self.expectation(description: "ProfileDiscovyerEndpoints")
        let discovery = ProfileDiscoveryRequest(for: profile)
        discovery.start {
            XCTAssertEqual(discovery.endpoints, profileKnownEndpoints)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // This test is a good one, because all the endpoints are in the HTTP Link headers EXCEPT the webmention endpoint, that is located in the HTML
    // So if this test fails there is either something wrong with the Link header code OR the HTML parsing code
    func testProfileDiscoveryEndpointsBoth() {
        
        let profile = URL(string: "https://aaronpk.com")!
        let profileKnownEndpoints = [EndpointType.authorization_endpoint: URL(string: "https://aaronparecki.com/auth")!,
                                     EndpointType.token_endpoint: URL(string: "https://aaronparecki.com/auth/token")!,
                                     EndpointType.micropub: URL(string: "https://aaronparecki.com/micropub")!,
                                     EndpointType.microsub: URL(string: "https://aperture.p3k.io/microsub/1")!,
                                     EndpointType.webmention: URL(string: "https://webmention.io/aaronpk/webmention")!]
        let expectation = self.expectation(description: "ProfileDiscovyerEndpoints")
        let discovery = ProfileDiscoveryRequest(for: profile)
        discovery.start {
            XCTAssertEqual(discovery.endpoints, profileKnownEndpoints)
            expectation.fulfill()
        }
    
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testProfileDiscoveryEndpointsRelative() {
        
        let profile = URL(string: "https://vanderven.se/martijn/")!
        let profileKnownEndpoints = [EndpointType.authorization_endpoint: URL(string: "https://vanderven.se/martijn/auth/")!,
                                     EndpointType.webmention: URL(string: "https://vanderven.se/martijn/mention.php")!]
        
//        let discovery = ProfileDiscoveryRequest(for: profile)
//        discovery.parseSiteData(response: HTTPURLResponse(), htmlData: nil)
        
        let expectation = self.expectation(description: "ProfileDiscovyerEndpoints")
        let discovery = ProfileDiscoveryRequest(for: profile)
        discovery.start {
            XCTAssertEqual(discovery.endpoints, profileKnownEndpoints)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func testAuthenticationRequest() {
        
    }
    
    // TODO: Write a test that returns several of the same endpoint and make sure that the FIRST endpoint is used
    
    static var allTests = [
        ("Test Valid Profile Urls", testValidProfileUrls),
        ("Test Invalid Profile Urls", testInvalidProfileUrls),
        //("Test Normalized Profile Urls", testNormalizeHostnameUrl),
        ("Test Profile Discovery", testProfileDiscoveryRedirection),
        ("Test Profile Discovery Endpoints for HTTP Link", testProfileDiscoveryEndpointsHTTPLink),
        ("Test Profile Discovery Endpoints for HTML", testProfileDiscoveryEndpointsHTML),
        ("Test Profile Discovery Endpoint Both", testProfileDiscoveryEndpointsBoth)
    ]
}
