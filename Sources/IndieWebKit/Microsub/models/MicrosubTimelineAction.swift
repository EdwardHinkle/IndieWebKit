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
    
    public init(with method: MicrosubTimelineMethodType, for channel: String, before entry: String) {
        self.method = method
        self.channel = channel
        self.lastReadEntry = entry
        self.entries = nil
    }
}
