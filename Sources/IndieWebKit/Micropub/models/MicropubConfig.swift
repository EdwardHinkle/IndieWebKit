//
//  MicropubConfig.swift
//  
//
//  Created by ehinkle-ad on 6/13/19.
//

import Foundation

// This is the value returned from the Micropub configuration query endpoint.
// See https://micropub.net/draft/#configuration for more information
public struct MicropubConfig: Codable {
    let mediaEndpoint: URL?
    let syndicateTo: [SyndicationTarget]?
    let postTypes: [SupportedPostType]? // This supports the Supported Vocabulary extension. See https://github.com/indieweb/micropub-extensions/issues/1
    let q: [MicropubQueryType]? // This supports the Supported Queries extension. See https://github.com/indieweb/micropub-extensions/issues/7
    
    enum CodingKeys: String, CodingKey {
        case mediaEndpoint = "media-endpoint"
        case syndicateTo = "syndicate-to"
        case postTypes = "post-types"
        case q
    }
}
