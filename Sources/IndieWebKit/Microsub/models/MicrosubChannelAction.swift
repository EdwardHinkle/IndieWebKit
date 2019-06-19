//
//  MicrosubChannelAction.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public struct MicrosubChannelAction: MicrosubAction {
    var action: MicrosubActionType
    var channel: String
    var url: URL? = nil
    
    public func httpMethodForRequest() -> HTTPMethod {
        if url == nil {
            return .GET
        }
        
        return .POST
    }
    
    public func convertToPostBody() -> Data? {
        var postBody: [String] = []
        
        postBody.append(createFormEncodedEntry(name: "action", value: action.rawValue))
        postBody.append(createFormEncodedEntry(name: "channel", value: channel))
        
        if url != nil {
            postBody.append(createFormEncodedEntry(name: "url", value: url!.absoluteString))
        }
        
        return postBody.joined(separator: "&").data(using: .utf8, allowLossyConversion: false)
    }
}
