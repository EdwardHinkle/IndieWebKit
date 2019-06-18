import XCTest
@testable import IndieWebKit

let micropubRocksClient = "https://micropub.rocks/client/HTSxBUnl2jHeMh1Y"
let micropubEndpoint = URL(string: "\(micropubRocksClient)/micropub")!
let accessToken = "BGp5NuExxhtVYiukM0NlC4mr3mczuMt8vxvNlUMkmaUMqKXdh6pUpmOZGd5dniVr257CyS4WKP4jgssd7JPx4CHln260pw0jQpL11bworiQ0E19b7xNnWMtCJX265XTq"

final class MicropubTests: XCTestCase {
    
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
            XCTAssertEqual(config!.mediaEndpoint, URL(string: "\(micropubRocksClient)/media")!)
            XCTAssertNotNil(config!.syndicateTo)
            XCTAssertEqual(config!.syndicateTo?.count, 1)
            XCTAssertEqual(config!.syndicateTo?[0].uid, "https://news.indieweb.org/en")
            XCTAssertEqual(config!.syndicateTo?[0].name, "IndieNews")
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub spec 3.7.3 Syndication Targets Query
    // https://micropub.net/draft/#configuration
    // Micropub.rocks test 601
    func testMicropubSyndicationTargetQueryMicropubRocks() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        
        let waiting = expectation(description: "Retrieve Micropub Syndication Targets")
        try! micropub.getSyndicationTargetQuery { syndicationTargets in
            XCTAssertNotNil(syndicationTargets)
            XCTAssertEqual(syndicationTargets?.count, 1)
            XCTAssertEqual(syndicationTargets?[0].uid, "https://news.indieweb.org/en")
            XCTAssertEqual(syndicationTargets?[0].name, "IndieNews")
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
    
    // Micropub spec 3.5 Delete Posts
    // https://micropub.net/draft/#delete
    // Micropub.rocks test 500
    func testMicropubDelete() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry, url: URL(string: "\(micropubRocksClient)/500/ZZLy8uMe")!)
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .FormEncoded, with: .delete) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertEqual(postUrl, post.url)
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub spec 3.5 Undelete Posts
    // https://micropub.net/draft/#delete
    // Micropub.rocks test 502
    func testMicropubUndelete() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry, url: URL(string: "\(micropubRocksClient)/502/mk1U37Oz")!)
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .FormEncoded, with: .undelete) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertEqual(postUrl, post.url)
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 100
    func testCreateHEntryPostAsFormEncoded() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry, content: "Hello World!")
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .FormEncoded) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertTrue(postUrl!.absoluteString.hasPrefix("\(micropubRocksClient)/100"))
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 101
    func testCreateHEntryPostWithCategoriesAsFormEncoded() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry, content: "Hello World!", categories: ["indieweb", "swift", "indiewebkit"])
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .FormEncoded) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertTrue(postUrl!.absoluteString.hasPrefix("\(micropubRocksClient)/101"))
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 104
    func testCreateHEntryPostWithFileUrlAsFormEncoded() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry,
                                content: "Hello World!",
                                externalPhoto: [ExternalFile(value: URL(string: "https://eddiehinkle.com/images/profile.jpg")!)])
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .FormEncoded) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertTrue(postUrl!.absoluteString.hasPrefix("\(micropubRocksClient)/104"))
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 105
    func testCreateHEntryPostWithSyndicationAsFormEncoded() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry,
                                content: "Hello World!",
                                syndicateTo: [SyndicationTarget(uid: "https://news.indieweb.org/en", name: "IndieNews", service: nil, user: nil)])
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .FormEncoded) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertTrue(postUrl!.absoluteString.hasPrefix("\(micropubRocksClient)/105"))
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 200
    func testCreateHEntryPostAsJSON() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry, content: "Hello World!")
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .JSON) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertTrue(postUrl!.absoluteString.hasPrefix("\(micropubRocksClient)/200"))
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 201
    func testCreateHEntryPostWithCategoriesAsJSON() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry, content: "Hello World!", categories: ["indieweb", "swift", "indiewebkit"])
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .JSON) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertTrue(postUrl!.absoluteString.hasPrefix("\(micropubRocksClient)/201"))
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 203
    func testCreateHEntryPostWithFileUrlAsJSON() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry,
                                content: "Hello World!",
                                externalPhoto: [ExternalFile(value: URL(string: "https://eddiehinkle.com/images/profile.jpg")!)])
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .JSON) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertTrue(postUrl!.absoluteString.hasPrefix("\(micropubRocksClient)/203"))
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 202
    func testCreateHEntryPostWithHTMLAsJSON() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry,
                                htmlContent: "<b>Testing</b>")
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .JSON) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertTrue(postUrl!.absoluteString.hasPrefix("\(micropubRocksClient)/202"))
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 205
    func testCreateHEntryPostWithPhotoAltTextAsJSON() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry,
                                externalPhoto: [ExternalFile(value: URL(string: "https://eddiehinkle.com/images/profile.jpg")!, alt: "Alt Text")])
        
        let waiting = expectation(description: "Send Micropub Request")
        try! micropub.sendMicropubPost(post, as: .JSON) { postUrl in
            XCTAssertNotNil(postUrl)
            XCTAssertTrue(postUrl!.absoluteString.hasPrefix("\(micropubRocksClient)/205"))
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 602
    func testSourceQueryAllProperties() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry,
                                url: URL(string: "https://micropub.rocks/client/HTSxBUnl2jHeMh1Y/602/twS9JbaM")!)
        
        let waiting = expectation(description: "Send Source Query")
        try! micropub.getSourceQuery(for: post) { returnedPost in
            XCTAssertNotNil(returnedPost)
            XCTAssertEqual(returnedPost!.count, 1)
            XCTAssertEqual(returnedPost![0].content, "Hello world")
            XCTAssertNotNil(returnedPost![0].categories)
            XCTAssertEqual(returnedPost![0].categories!.count, 2)
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Micropub.rocks test 603
    func testSourceQuerySomeProperties() {
        let micropub = MicropubSession(to: micropubEndpoint, with: accessToken)
        let post = MicropubPost(type: .entry,
                                url: URL(string: "https://micropub.rocks/client/HTSxBUnl2jHeMh1Y/602/twS9JbaM")!)
        
        let waiting = expectation(description: "Send Source Query")
        try! micropub.getSourceQuery(for: post, with: [.categories, .content]) { returnedPost in
            XCTAssertNotNil(returnedPost)
            XCTAssertEqual(returnedPost!.count, 1)
            XCTAssertEqual(returnedPost![0].content, "Hello world")
            XCTAssertNotNil(returnedPost![0].categories)
            XCTAssertEqual(returnedPost![0].categories!.count, 2)
            waiting.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    static var allTests = [
        ("Create form encoded h-entry post", testCreateFormEncodedHEntryPost),
        ("Test Micropub Config", testMicropubConfigMicropubRocks)
    ]
}
