//
//  IndieAuthError.swift
//  
//
//  Created by ehinkle-ad on 6/12/19.
//

import Foundation
enum IndieAuthError: Error {
    case authenticationError(String)
    case authorizationError(String)
    case revocationError(String)
}
