//
//  MicropubPost.swift
//  
//
//  Created by ehinkle-ad on 6/14/19.
//

import Foundation
public struct MicropubPost {
    var type: MicropubPostType?
    var url: URL?
    var content: String?
    var categories: [String]?
    var externalPhoto: [URL]?
    var externalVideo: [URL]?
    var externalAudio: [URL]?
    var syndicateTo: [SyndicationTarget]?
}
