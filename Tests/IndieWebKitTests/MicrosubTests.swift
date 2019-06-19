import XCTest
@testable import IndieWebKit

let microsubEndpoint = URL(string: "https://example.com/microsub")!
let microsubAccessToken = "odiajiosdjoasijdioasjdoij"

final class MicrosubTests: XCTestCase {
    
    func testMicrosubRequestHeaders() {
        let action = MicrosubTimelineAction(markAsReadIn: "channelTestName", before: "LastEntryId")
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        
        let headers = request.allHTTPHeaderFields
        XCTAssertNotNil(headers)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(headers!["Content-Type"], MicropubSendType.FormEncoded.rawValue)
        XCTAssertEqual(headers!["Authorization"], "Bearer \(microsubAccessToken)")
    }
    
    func testMarkLastEntriesAsRead() {
        let action = MicrosubTimelineAction(markAsReadIn: "channelTestName", before: "LastEntryId")
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_read"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("last_read_entry=LastEntryId"))
    }
    
    func testMarkMultipleEntriesAsRead() {
        let action = MicrosubTimelineAction(with: .markRead, for: "channelTestName", on: ["entry1", "entry2"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_read"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry[]=entry1&entry[]=entry2"))
    }
    
    func testMarkMultipleEntriesAsUnread() {
        let action = MicrosubTimelineAction(with: .markUnread, for: "channelTestName", on: ["entry1", "entry2"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_unread"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry[]=entry1&entry[]=entry2"))
    }
    
    func testMarkSingleEntryAsRead() {
        let action = MicrosubTimelineAction(with: .markRead, for: "channelTestName", on: ["entryId"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_read"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry=entryId"))
    }
    
    func testMarkSingleEntryAsUnread() {
        let action = MicrosubTimelineAction(with: .markUnread, for: "channelTestName", on: ["entryId"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=mark_unread"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry=entryId"))
    }
    
    func testRemoveEntryFromChannel() {
        let action = MicrosubTimelineAction(with: .remove, for: "channelTestName", on: ["entryId"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=remove"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry=entryId"))
    }
    
    func testRemoveMultipleEntriesFromChannel() {
        let action = MicrosubTimelineAction(with: .remove, for: "channelTestName", on: ["entry1", "entry2"])
        let request = try! action.generateRequest(for: microsubEndpoint, with: microsubAccessToken)
        let body = String(data: request.httpBody!, encoding: .utf8)
        
        XCTAssertNotNil(body)
        XCTAssertTrue(body!.contains("action=timeline"))
        XCTAssertTrue(body!.contains("method=remove"))
        XCTAssertTrue(body!.contains("channel=channelTestName"))
        XCTAssertTrue(body!.contains("entry[]=entry1&entry[]=entry2"))
    }
    
}
