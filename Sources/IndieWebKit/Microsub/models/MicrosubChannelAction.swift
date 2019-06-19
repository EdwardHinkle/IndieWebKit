//
//  MicrosubChannelAction.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public struct MicrosubChannelAction: Codable {
    var action: MicrosubActionType
    var channel: String
    var url: URL?
}
