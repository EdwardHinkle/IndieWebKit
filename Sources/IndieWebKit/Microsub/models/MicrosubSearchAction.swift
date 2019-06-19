//
//  MicrosubSearchAction.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public struct MicrosubSearchAction: MicrosubAction {
    let action = "search"
    var query: String
    
    public func httpMethodForRequest() -> HTTPMethod {
        return .POST
    }
    
    public func convertToPostBody() -> Data? {
        var postBody: [String] = []
        
        postBody.append(createFormEncodedEntry(name: "action", value: action))
        postBody.append(createFormEncodedEntry(name: "query", value: query))
        
        return postBody.joined(separator: "&").data(using: .utf8, allowLossyConversion: false)
    }
}
