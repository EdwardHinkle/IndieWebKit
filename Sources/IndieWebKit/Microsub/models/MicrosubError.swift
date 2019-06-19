//
//  MicrosubError.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
enum MicrosubError: Error {
    case generalError(String)
    case serverError(statusCode: Int, description: String)
}
