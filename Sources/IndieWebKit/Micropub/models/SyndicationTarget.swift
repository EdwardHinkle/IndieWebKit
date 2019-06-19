//
//  SyndicationTarget.swift
//  
//
//  Created by ehinkle-ad on 6/13/19.
//

import Foundation
public struct SyndicationTarget: Codable {
    let uid: String
    let name: String
    let service: SyndicationTargetCard?
    let user: SyndicationTargetCard?
}
