//
//  MicropubSendType.swift
//  
//
//  Created by ehinkle-ad on 6/14/19.
//

import Foundation
public enum MicropubSendType: String {
    case FormEncoded = "application/x-www-form-urlencoded"
    case Multipart = "multipart/form-data"
    case JSON = "application/json"
}
