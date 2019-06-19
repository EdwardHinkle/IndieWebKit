//
//  MicrosubActionType.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public enum MicrosubActionType: String, Codable {
    case follow
    case unfollow
    case mute
    case unmute
    case block
}
