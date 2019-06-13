//
//  PostType.swift
//  
//
//  Created by ehinkle-ad on 6/13/19.
//

import Foundation

// The enum value becomes the "type" of supported post type, and the associated String is the name used by the server
public enum PostType: String {
    case note(String)
    case article(String)
    case photo(String)
    case video(String)
    case reply(String)
    case like(String)
    case repost(String)
    case rsvp(String)
    case bookmark(String)
}
