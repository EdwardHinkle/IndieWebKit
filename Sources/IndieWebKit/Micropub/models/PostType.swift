//
//  PostType.swift
//  
//
//  Created by ehinkle-ad on 6/13/19.
//

import Foundation

// The enum value becomes the "type" of supported post type
public enum PostType: String, Codable {
    case note
    case article
    case photo
    case video
    case reply
    case like
    case repost
    case rsvp
    case bookmark
}
