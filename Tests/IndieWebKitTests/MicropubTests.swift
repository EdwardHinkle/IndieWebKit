import XCTest
@testable import IndieWebKit

final class MicropubTests: XCTestCase {
    
    let micropubEndpoint = URL(string: "https://micropub.rocks/client/HTSxBUnl2jHeMh1Y/micropub")!
    let accessToken = "80ntMvtkk7LfoJGUJraX5bUrNjbJn1AXKZLaW9zebcSrAyyPKcGjNpY3DfL0q2XoaKNhpTtoUzEQoYiaSaJSCZS0V0OFHhVQF1VJo6ngzd2mK2MwKLahsdkqGDIwN9xr"
    
    // Micropub.rocks 100 - Create an h-entry post (form-encoded)
    func testCreateFormEncodedHEntryPost() {
//        XCTAssertTrue(false)
    }
    
    // Micropub spec 3.7.1 Configuration Query
    // https://micropub.net/draft/#configuration
    // Micropub.rocks test 600
    func testMicropubConfig() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        
        let waiting = expectation(description: "Retrieve Micropub Config")
        try! micropub.getConfigQuery { config in
            XCTAssertNotNil(config)
            XCTAssertNotNil(config!.mediaEndpoint)
            XCTAssertEqual(config!.mediaEndpoint, URL(string: "https://micropub.rocks/client/HTSxBUnl2jHeMh1Y/media")!)
            XCTAssertNotNil(config!.syndicateTo)
            XCTAssertEqual(config!.syndicateTo?.count, 1)
            XCTAssertEqual(config!.syndicateTo?[0].uid, "https://news.indieweb.org/en")
            XCTAssertEqual(config!.syndicateTo?[0].name, "IndieNews")
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    static var allTests = [
        ("Create form encoded h-entry post", testCreateFormEncodedHEntryPost),
        ("Test Micropub Config", testMicropubConfig)
    ]
}
