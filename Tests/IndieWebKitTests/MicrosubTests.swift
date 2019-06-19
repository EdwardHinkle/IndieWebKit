import XCTest
@testable import IndieWebKit

let microsubEndpoint = URL(string: "https://example.com/microsub")!
let microsubAccessToken = "odiajiosdjoasijdioasjdoij"

final class MicrosubTests: XCTestCase {
    
    func testMicrosubRequestHeadersRequest() {
        let action = MicrosubTimelineAction(markAsReadIn: "channelTestName", before: "LastEntryId")
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        
        let headers = request.allHTTPHeaderFields
        XCTAssertNotNil(headers)
        XCTAssertEqual(headers!["Content-Type"], MicropubSendType.FormEncoded.rawValue)
        XCTAssertEqual(headers!["Authorization"], "Bearer \(microsubAccessToken)")
    }
    
    func testMarkLastEntriesAsReadRequest() {
        let action = MicrosubTimelineAction(markAsReadIn: "channelTestName", before: "LastEntryId")
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_read"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("last_read_entry=LastEntryId"))
    }
    
    func testMarkMultipleEntriesAsReadRequest() {
        let action = MicrosubTimelineAction(with: .markRead, for: "channelTestName", on: ["entry1", "entry2"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_read"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry[]=entry1&entry[]=entry2"))
    }
    
    func testMarkMultipleEntriesAsUnreadRequest() {
        let action = MicrosubTimelineAction(with: .markUnread, for: "channelTestName", on: ["entry1", "entry2"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_unread"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry[]=entry1&entry[]=entry2"))
    }
    
    func testMarkSingleEntryAsReadRequest() {
        let action = MicrosubTimelineAction(with: .markRead, for: "channelTestName", on: ["entryId"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_read"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry=entryId"))
    }
    
    func testMarkSingleEntryAsUnreadRequest() {
        let action = MicrosubTimelineAction(with: .markUnread, for: "channelTestName", on: ["entryId"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_unread"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry=entryId"))
    }
    
    func testRemoveEntryFromChannelRequest() {
        let action = MicrosubTimelineAction(with: .remove, for: "channelTestName", on: ["entryId"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=remove"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry=entryId"))
    }
    
    func testRemoveMultipleEntriesFromChannelRequest() {
        let action = MicrosubTimelineAction(with: .remove, for: "channelTestName", on: ["entry1", "entry2"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=remove"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry[]=entry1&entry[]=entry2"))
    }
    
    func testSearchFeedsRequest() {
        let searchDomain = "eddiehinkle.com"
        let action = MicrosubSearchAction(query: searchDomain)
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=search"))
        XCTAssertTrue(body!.contains("query=\(searchDomain.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"))
    }
    
    func testPreviewFeedsRequest() {
        let previewUrl = URL(string: "https://eddiehinkle.com/timeline")!
        let action = MicrosubPreviewAction(url: previewUrl)
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=preview"))
        XCTAssertTrue(body!.contains("url=\(previewUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"))
    }
    
    func testFollowFeedRequest() {
        let followUrl = URL(string: "https://eddiehinkle.com/timeline")!
        let followChannel = "channelToFollowIn"
        
        let action = MicrosubChannelAction(action: .follow, channel: followChannel, url: followUrl)
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=follow"))
        XCTAssertTrue(body!.contains("channel=\(followChannel)"))
        XCTAssertTrue(body!.contains("url=\(followUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"))
    }
    
    func testUnfollowFeedRequest() {
        let unfollowUrl = URL(string: "https://eddiehinkle.com/timeline")!
        let unfollowChannel = "channelToUnfollowIn"
        
        let action = MicrosubChannelAction(action: .unfollow, channel: unfollowChannel, url: unfollowUrl)
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=unfollow"))
        XCTAssertTrue(body!.contains("channel=\(unfollowChannel)"))
        XCTAssertTrue(body!.contains("url=\(unfollowUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"))
    }
    
    func testGetFollowingListRequest() {
        let followChannel = "channelToFollowIn"
        
        let action = MicrosubChannelAction(action: .follow, channel: followChannel)
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=follow"))
        XCTAssertTrue(body!.contains("channel=\(followChannel)"))
    }
    
}
