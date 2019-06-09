//
//  EndpointType.swift
//  
//
//  Created by Edward Hinkle on 6/9/19.
//

import Foundation
public enum EndpointType: String, CaseIterable {
    case authorization_endpoint
    case token_endpoint
    case micropub
    case microsub
    case webmention
}
