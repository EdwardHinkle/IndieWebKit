//
//  MicrosubChannelModifyAction.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public struct MicrosubChannelModifyAction: Codable {
    let action = "channels"
    var name: String?
    var channel: String?
    var method: String?
    
    init(create name: String) {
        self.name = name
        self.channel = nil
    }
    
    init(update channel: String, with name: String) {
        self.name = name
        self.channel = channel
    }
    
    init(delete channel: String) {
        self.name = nil
        self.channel = channel
        self.method = "delete"
    }
}
