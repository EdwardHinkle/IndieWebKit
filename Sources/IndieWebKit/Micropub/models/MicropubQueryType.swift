//
//  MicropubQueryType.swift
//  
//
//  Created by ehinkle-ad on 6/13/19.
//

import Foundation

// This defines the types of Micropub queries that this framework knows about..
// For more information, see: https://indieweb.org/Micropub-extensions
public enum MicropubQueryType: String {
    case source
    case syndicateTo = "syndicate-to"
    case category
    case contact
}
