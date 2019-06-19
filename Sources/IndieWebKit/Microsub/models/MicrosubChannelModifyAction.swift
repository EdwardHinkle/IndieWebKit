//
//  MicrosubChannelModifyAction.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public struct MicrosubChannelAction: MicrosubAction {
    let action = "channels"
    var name: String?
    var channel: String?
    var method: String?
    
    init() {
        self.name = nil
        self.channel = nil
        self.method = nil
    }
    
    init(create name: String) {
        self.name = name
        self.channel = nil
        self.method = nil
    }
    
    init(update channel: String, with name: String) {
        self.name = name
        self.channel = channel
        self.method = nil
    }
    
    init(delete channel: String) {
        self.name = nil
        self.channel = channel
        self.method = "delete"
    }
    
    public func httpMethodForRequest() -> HTTPMethod {
        if  self.name == nil,
            self.channel == nil,
            self.method == nil {
            
            return .GET
        }
        
        return .POST
    }
    
    public func convertToPostBody() -> Data? {
        var postBody: [String] = []
        
        postBody.append(createFormEncodedEntry(name: "action", value: action))
        
        if name != nil {
            postBody.append(createFormEncodedEntry(name: "name", value: name!))
        }
        
        if channel != nil {
            postBody.append(createFormEncodedEntry(name: "channel", value: channel!))
        }
        
        if method != nil {
            postBody.append(createFormEncodedEntry(name: "method", value: method!))
        }
        
        return postBody.joined(separator: "&").data(using: .utf8, allowLossyConversion: false)
    }
}
