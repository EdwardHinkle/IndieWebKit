//
//  PostType.swift
//  
//
//  Created by ehinkle-ad on 6/13/19.
//

import Foundation

// The enum value becomes the "type" of supported post type, and the associated String is the name used by the server
public enum PostType {
    case note(String)
    case article(String)
    case photo(String)
    case video(String)
    case reply(String)
    case like(String)
    case repost(String)
    case rsvp(String)
    case bookmark(String)
    
    var value: String {
        switch self {
        case .note:
            return "note"
        case .article:
            return "article"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .reply:
            return "reply"
        case .like:
            return "like"
        case .repost:
            return "repost"
        case .rsvp:
            return "rsvp"
        case .bookmark:
            return "bookmark"
        }
    }
}
