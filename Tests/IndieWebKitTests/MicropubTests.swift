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
    func testMicropubConfigMicropubRocks() {
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
    
    // Micropub spec 3.7.1 Configuration Query
    // https://micropub.net/draft/#configuration
    // Test against Micro.blog
//    func testMicropubConfigMicroDotBlog() {
//        let micropub = MicropubSession(to: URL(string: "https://micro.blog/micropub")!, with: "")
//
//        let waiting = expectation(description: "Retrieve Micropub Config")
//        try! micropub.getConfigQuery { config in
//            XCTAssertNotNil(config)
//            XCTAssertNotNil(config!.mediaEndpoint)
//            XCTAssertEqual(config!.mediaEndpoint, URL(string: "https://micro.blog/micropub/media")!)
//            XCTAssertNotNil(config!.postTypes)
//            XCTAssertEqual(config!.postTypes?.count, 5)
//            XCTAssertEqual(config!.postTypes?[0].type, .note)
//            XCTAssertEqual(config!.postTypes?[0].name, "Post")
//            XCTAssertEqual(config!.postTypes?[1].type, .article)
//            XCTAssertEqual(config!.postTypes?[1].name, "Article")
//            XCTAssertEqual(config!.postTypes?[2].type, .photo)
//            XCTAssertEqual(config!.postTypes?[2].name, "Photo")
//            XCTAssertEqual(config!.postTypes?[3].type, .reply)
//            XCTAssertEqual(config!.postTypes?[3].name, "Reply")
//            XCTAssertEqual(config!.postTypes?[4].type, .bookmark)
//            XCTAssertEqual(config!.postTypes?[4].name, "Favorite")
//            XCTAssertNotNil(config!.destination)
//            XCTAssertEqual(config!.destination?.count, 1)
//            XCTAssertEqual(config!.destination?[0].uid, "https://30andcounting.micro.blog/")
//            XCTAssertEqual(config!.destination?[0].name, "30andcounting.micro.blog")
//            waiting.fulfill()
//        }
//
//        waitForExpectations(timeout: 5, handler: nil)
//    }
    
    static var allTests = [
        ("Create form encoded h-entry post", testCreateFormEncodedHEntryPost),
        ("Test Micropub Config", testMicropubConfigMicropubRocks)
    ]
}
