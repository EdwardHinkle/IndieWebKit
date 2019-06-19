//
//  MicrosubAction.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
public protocol MicrosubAction: Codable {
    func generateRequest(for endpoint: URL, with token: String) throws -> URLRequest
    func convertToPostBody() -> Data?
}
