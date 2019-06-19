//
//  MicrosubPreviewAction.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public struct MicrosubPreviewAction: MicrosubAction {
    let action = "preview"
    var url: URL
    
    public func convertToPostBody() -> Data? {
        var postBody: [String] = []
        
        postBody.append(createFormEncodedEntry(name: "action", value: action))
        postBody.append(createFormEncodedEntry(name: "url", value: url.absoluteString))
        
        return postBody.joined(separator: "&").data(using: .utf8, allowLossyConversion: false)
    }
}
