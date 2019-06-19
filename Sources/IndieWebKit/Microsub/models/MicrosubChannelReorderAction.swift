//
//  MicrosubChannelReorderAction.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public struct MicrosubChannelReorderAction: MicrosubAction {
    let action = "channels"
    let method = "order"
    var channels: [String]
}
