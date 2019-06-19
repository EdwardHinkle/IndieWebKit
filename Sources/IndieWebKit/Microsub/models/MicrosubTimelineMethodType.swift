//
//  MicrosubTimelineMethodType.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public enum MicrosubTimelineMethodType: String, Codable {
    case markRead = "mark_read"
    case markUnread = "mark_unread"
    case remove = "remove"
}
