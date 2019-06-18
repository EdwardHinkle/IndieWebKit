//
//  MicropubVisibility.swift
//  
//
//  Created by ehinkle-ad on 6/18/19.
//

import Foundation
public enum MicropubVisibility: String, Codable {
    case open = "public" // Public is a protected keyword in swift
    case closed = "private" // private is a protected keyword in swift
    case unlisted
    case protected
}
