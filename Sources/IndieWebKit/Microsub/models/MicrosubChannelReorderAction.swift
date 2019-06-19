//
//  MicrosubChannelReorderAction.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public struct MicrosubChannelReorderAction: MicrosubAction {
    let action = "channels"
    let method = "order"
    var channels: [String]
    
    public func httpMethodForRequest() -> HTTPMethod {
        return .POST
    }
    
    public func convertToPostBody() -> Data? {
        var postBody: [String] = []
        
        postBody.append(createFormEncodedEntry(name: "action", value: action))
        postBody.append(createFormEncodedEntry(name: "method", value: method))
        postBody.append(createFormEncodedEntry(name: "channels", value: channels))
        
        return postBody.joined(separator: "&").data(using: .utf8, allowLossyConversion: false)
    }
}
