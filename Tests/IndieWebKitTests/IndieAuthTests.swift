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
    
    // IndieAuth Spec 5.2 Building Authentication Request URL
    // https://indieauth.spec.indieweb.org/#authentication-request
    func testAuthenticationRequestUrl() {
        
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        
        let request = IndieAuthRequest(.Authentication,
                              for: profile,
                              at: authorization_endpoint,
                              clientId: client_id,
                              redirectUri: redirect_uri,
                              state: state)
     
        XCTAssertTrue(request.url!.absoluteString.hasPrefix("\(authorization_endpoint)?me=\(profile)&client_id=\(client_id)&redirect_uri=\(redirect_uri)&state=\(state)&response_type=id&code_challenge_method=S256&code_challenge="))
    }
    
    // IndieAuth Spec 5.3 Parsing the Authentication Response
    // https://indieauth.spec.indieweb.org/#authentication-response
    func testParseAuthenticationResponse() {
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        
        let request = IndieAuthRequest(.Authentication,
                                        for: profile,
                                        at: authorization_endpoint,
                                        clientId: client_id,
                                        redirectUri: redirect_uri,
                                        state: state)
        
        let authorization_code_from_server = String.randomAlphaNumericString(length: 20)
        
        let parsed_authorization_code = request.parseResponse(URL(string: "\(redirect_uri)?code=\(authorization_code_from_server)&state=\(state)")!)
        XCTAssertEqual(parsed_authorization_code, authorization_code_from_server)
    }
    
    // IndieAuth Spec 5.4 Authorization Code Verification Request
    // https://indieauth.spec.indieweb.org/#authorization-code-verification
    func testAuthorizationCodeVerificationRequest() {
        
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        
        let request = IndieAuthRequest(.Authentication,
                                        for: profile,
                                        at: authorization_endpoint,
                                        clientId: client_id,
                                        redirectUri: redirect_uri,
                                        state: state)
        
        let authorization_code = String.randomAlphaNumericString(length: 20)
        
        let verificationRequest: URLRequest = try! request.getVerificationRequest(with: authorization_code)
        
        XCTAssertEqual(verificationRequest.httpMethod, "POST")
        XCTAssertEqual(verificationRequest.url, authorization_endpoint)
        
        let bodyDictionary = try! JSONDecoder().decode([String:String].self, from: verificationRequest.httpBody!)
        
        XCTAssertEqual(bodyDictionary["code"], authorization_code)
        XCTAssertEqual(bodyDictionary["client_id"], client_id.absoluteString)
        XCTAssertEqual(bodyDictionary["redirect_uri"], redirect_uri.absoluteString)
        XCTAssertTrue(request.checkCodeChallenge(bodyDictionary["code_verifier"]!))
    }
    
    // IndieAuth Spec 5.4 Authorization Code Verification Response
    // https://indieauth.spec.indieweb.org/#authorization-code-verification
    func testAuthorizationCodeVerificationResponse() {
        
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        
        let request = IndieAuthRequest(.Authentication,
                                        for: profile,
                                        at: authorization_endpoint,
                                        clientId: client_id,
                                        redirectUri: redirect_uri,
                                        state: state)
        
        let sameProfile = profile
        let responseWithSameProfile = [ "me": sameProfile ]
        let isValidMe = request.confirmVerificationResponse(responseWithSameProfile)
        XCTAssertTrue(isValidMe)
        
        var subProfile = URLComponents(url: profile, resolvingAgainstBaseURL: false)!
        subProfile.path = "/path/under"
        let responseWithSubProfile = [ "me": subProfile.url! ]
        let isValidMe2 = request.confirmVerificationResponse(responseWithSubProfile)
        XCTAssertTrue(isValidMe2)
        
        let spoofedProfile = URL(string: "https://spoofing.com")!
        let responseWithSpoofedProfile = [ "me": spoofedProfile ]
        let isValidMe3 = request.confirmVerificationResponse(responseWithSpoofedProfile)
        XCTAssertFalse(isValidMe3)
    }
    
    // IndieAuth Spec 6.2.1 Building Authorization Request URL
    // https://indieauth.spec.indieweb.org/#authorization-request
    func testAuthorizationRequestUrl() {
        
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        let scope = ["create", "update", "delete"]
        
        let requestWithoutScope = IndieAuthRequest(.Authorization,
                                       for: profile,
                                       at: authorization_endpoint,
                                       clientId: client_id,
                                       redirectUri: redirect_uri,
                                       state: state)
        
        XCTAssertTrue(requestWithoutScope.url!.absoluteString.hasPrefix("\(authorization_endpoint)?me=\(profile)&client_id=\(client_id)&redirect_uri=\(redirect_uri)&state=\(state)&response_type=code&code_challenge_method=S256&code_challenge="))
        
        let requestWithScope = IndieAuthRequest(.Authorization,
                                                   for: profile,
                                                   at: authorization_endpoint,
                                                   clientId: client_id,
                                                   redirectUri: redirect_uri,
                                                   state: state,
                                                   scope: scope)
        
        XCTAssertTrue(requestWithScope.url!.absoluteString.hasPrefix("\(authorization_endpoint)?me=\(profile)&client_id=\(client_id)&redirect_uri=\(redirect_uri)&state=\(state)&scope=create%20update%20delete&response_type=code&code_challenge_method=S256&code_challenge="))
    }
    
    // IndieAuth Spec 6.2.2 Parsing the Authorization Response
    // https://indieauth.spec.indieweb.org/#authorization-response
    func testParseAuthorizationResponse() {
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        
        let request = IndieAuthRequest(.Authorization,
                                       for: profile,
                                       at: authorization_endpoint,
                                       clientId: client_id,
                                       redirectUri: redirect_uri,
                                       state: state)
        
        let authorization_code_from_server = String.randomAlphaNumericString(length: 20)
        
        let parsed_authorization_code = request.parseResponse(URL(string: "\(redirect_uri)?code=\(authorization_code_from_server)&state=\(state)")!)
        XCTAssertEqual(parsed_authorization_code, authorization_code_from_server)
    }
    
    // IndieAuth Spec 6.3.1 Generate Token Request
    // https://indieauth.spec.indieweb.org/#token-request
    func testTokenRequest() {
        
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let token_endpoint = URL(string: "https://eddiehinkle.com/auth/token")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        
        let request = IndieAuthRequest(.Authorization,
                                       for: profile,
                                       at: authorization_endpoint,
                                       with: token_endpoint,
                                       clientId: client_id,
                                       redirectUri: redirect_uri,
                                       state: state)
        
        let authorization_code = String.randomAlphaNumericString(length: 20)
        
        let tokenRequest: URLRequest = try! request.getTokenRequest(with: authorization_code)
        
        XCTAssertEqual(tokenRequest.httpMethod, "POST")
        XCTAssertEqual(tokenRequest.url, token_endpoint)
        
        let bodyDictionary = try! JSONDecoder().decode([String:String].self, from: tokenRequest.httpBody!)
        
        XCTAssertEqual(bodyDictionary["grant_type"], "authorization_code")
        XCTAssertEqual(bodyDictionary["code"], authorization_code)
        XCTAssertEqual(bodyDictionary["client_id"], client_id.absoluteString)
        XCTAssertEqual(bodyDictionary["redirect_uri"], redirect_uri.absoluteString)
        XCTAssertEqual(bodyDictionary["me"], profile.absoluteString)
        XCTAssertTrue(request.checkCodeChallenge(bodyDictionary["code_verifier"]!))
    }
    
    // IndieAuth Spec 6.3.3 Access Token Response
    // https://indieauth.spec.indieweb.org/#access-token-response
    func testTokenResponse() {
        
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let token_endpoint = URL(string: "https://eddiehinkle.com/auth/token")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        
        let request = IndieAuthRequest(.Authorization,
                                       for: profile,
                                       at: authorization_endpoint,
                                       with: token_endpoint,
                                       clientId: client_id,
                                       redirectUri: redirect_uri,
                                       state: state)
        
        let access_token_from_server = String.randomAlphaNumericString(length: 25)
        let token_type = "Bearer"
        let scope_from_server = "create update delete"
        let me_profile = profile
        
        let responseFromServer: [String:String] = [
            "access_token": access_token_from_server,
            "token_type": token_type,
            "scope": scope_from_server,
            "me": me_profile.absoluteString
        ]
        
        let returnData = try! JSONEncoder().encode(responseFromServer)
        let (tokenType, accessToken) = try! request.parseTokenResponse(returnData)
        
        XCTAssertEqual(request.scope.joined(separator: " "), responseFromServer["scope"])
        XCTAssertEqual(request.profile.absoluteString, responseFromServer["me"])
        XCTAssertEqual(tokenType, token_type)
        XCTAssertEqual(accessToken, access_token_from_server)
    }
    
    // IndieAuth Spec 6.3.3 Access Token Response
    // https://indieauth.spec.indieweb.org/#access-token-response
    func testTokenResponseWithSubProfile() {
        
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let token_endpoint = URL(string: "https://eddiehinkle.com/auth/token")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        
        let request = IndieAuthRequest(.Authorization,
                                       for: profile,
                                       at: authorization_endpoint,
                                       with: token_endpoint,
                                       clientId: client_id,
                                       redirectUri: redirect_uri,
                                       state: state)
        
        let access_token_from_server = String.randomAlphaNumericString(length: 25)
        let token_type = "Bearer"
        let scope_from_server = "create update delete"
        let me_profile = URL(string: "https://eddiehinkle.com/sub/profile")!
        
        let responseFromServer: [String:String] = [
            "access_token": access_token_from_server,
            "token_type": token_type,
            "scope": scope_from_server,
            "me": me_profile.absoluteString
        ]
        
        let returnData = try! JSONEncoder().encode(responseFromServer)
        let (tokenType, accessToken) = try! request.parseTokenResponse(returnData)
        
        XCTAssertEqual(request.scope.joined(separator: " "), responseFromServer["scope"])
        XCTAssertEqual(request.profile.absoluteString, responseFromServer["me"])
        XCTAssertEqual(tokenType, token_type)
        XCTAssertEqual(accessToken, access_token_from_server)
    }
    
    // IndieAuth Spec 6.3.3 Access Token Response
    // https://indieauth.spec.indieweb.org/#access-token-response
    func testTokenResponseWithInvalidProfile() {
        
        let profile = URL(string: "https://eddiehinkle.com")!
        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
        let token_endpoint = URL(string: "https://eddiehinkle.com/auth/token")!
        let client_id = URL(string: "https://remark.social")!
        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
        let state = String.randomAlphaNumericString(length: 25)
        
        let request = IndieAuthRequest(.Authorization,
                                       for: profile,
                                       at: authorization_endpoint,
                                       with: token_endpoint,
                                       clientId: client_id,
                                       redirectUri: redirect_uri,
                                       state: state)
        
        let access_token_from_server = String.randomAlphaNumericString(length: 25)
        let token_type = "Bearer"
        let scope_from_server = "create update delete"
        let me_profile = URL(string: "https://spoofing.com/profile")!
        
        let responseFromServer: [String:String] = [
            "access_token": access_token_from_server,
            "token_type": token_type,
            "scope": scope_from_server,
            "me": me_profile.absoluteString
        ]

        let returnData = try! JSONEncoder().encode(responseFromServer)
        var tokenType: String?, accessToken: String?
        
        do {
            (tokenType, accessToken) = try request.parseTokenResponse(returnData)
        } catch(IndieAuthError.authorizationError(let errorString)) {
            XCTAssertNotNil(errorString)
        } catch {
            // The error that should be caught should be above.
            // If we reach here, the logic has broken
            XCTAssertTrue(false)
        }
        
        XCTAssertEqual(request.scope.joined(separator: " "), "")
        XCTAssertEqual(request.profile.absoluteString, profile.absoluteString)
        XCTAssertNil(tokenType)
        XCTAssertNil(accessToken)
    }
    
    // IndieAuth Spec 6.3.5 Request Token Revocation
    // https://indieauth.spec.indieweb.org/#token-revocation
    func testTokenRevocationRequest() {
//        let profile = URL(string: "https://eddiehinkle.com")!
//        let authorization_endpoint = URL(string: "https://eddiehinkle.com/auth")!
//        let token_endpoint = URL(string: "https://eddiehinkle.com/auth/token")!
//        let client_id = URL(string: "https://remark.social")!
//        let redirect_uri = URL(string: "https://remark.social/ios/callback")!
//        let state = String.randomAlphaNumericString(length: 25)
//
//        let request = IndieAuthRequest(.Authorization,
//                                       for: profile,
//                                       at: authorization_endpoint,
//                                       with: token_endpoint,
//                                       clientId: client_id,
//                                       redirectUri: redirect_uri,
//                                       state: state)
//
//        let access_token_from_server = String.randomAlphaNumericString(length: 25)
//
//        request.
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
