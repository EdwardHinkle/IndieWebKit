//
//  File.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public struct MicrosubTimelineAction: MicrosubAction {
    let action = "timeline"
    var method: MicrosubTimelineMethodType
    var channel: String
    var entries: [String]?
    var lastReadEntry: String?
    
    public init(with method: MicrosubTimelineMethodType, for channel: String, on entries: [String]) {
        self.method = method
        self.channel = channel
        self.entries = entries
        self.lastReadEntry = nil
    }
    
    public init(markAsReadIn channel: String, before entry: String) {
        self.method = MicrosubTimelineMethodType.markRead
        self.channel = channel
        self.lastReadEntry = entry
        self.entries = nil
    }
    
    public func convertToPostBody() -> Data? {
        var postBody: [String] = []
        
        postBody.append(createFormEncodedEntry(name: "action", value: action))
        postBody.append(createFormEncodedEntry(name: "method", value: method.rawValue))
        postBody.append(createFormEncodedEntry(name: "channel", value: channel))
        
        if entries != nil {
            postBody.append(createFormEncodedEntry(name: "entry", value: entries!))
        }
        
        if lastReadEntry != nil {
            postBody.append(createFormEncodedEntry(name: "last_read_entry", value: lastReadEntry!))
        }
        
        return postBody.joined(separator: "&").data(using: .utf8, allowLossyConversion: false)
    }
}
