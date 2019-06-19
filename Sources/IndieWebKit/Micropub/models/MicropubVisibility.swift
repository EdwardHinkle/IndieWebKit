//
//  MicropubVisibility.swift
//  
//
//  Created by ehinkle-ad on 6/18/19.
//

import Foundation
public enum MicropubVisibility: String, Codable {
    case isPublic = "public" // Public is a protected keyword in swift
    case isPrivate = "private" // private is a protected keyword in swift
    case isUnlisted = "unlisted"
    case isProtected = "protected"
}
