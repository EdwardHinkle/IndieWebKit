//
//  MicrosubActionExtension.swift
//  
//
//  Created by ehinkle-ad on 6/19/19.
//

import Foundation
extension MicrosubAction {
    public func generateRequest(for microsubEndpoint: URL, with accessToken: String) throws -> URLRequest {
        var request = URLRequest(url: microsubEndpoint)
        request.httpMethod = self.httpMethodForRequest().rawValue
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue(MicropubSendType.FormEncoded.rawValue, forHTTPHeaderField: "Content-Type")
        request.addValue("IndieWebKit", forHTTPHeaderField: "X-Powered-By")
        
        let postBody = self.convertToPostBody()
        
        guard postBody != nil else {
            throw MicrosubError.generalError("Microsub Action couldn't be converted into a post body")
        }
        request.httpBody = postBody
        return request
    }
    
    public func createFormEncodedEntry(name: String, value: String) -> String {
        if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return "\(name)=\(encodedValue)"
        }
        return ""
    }
    
    public func createFormEncodedEntry(name: String, value: [String]) -> String {
        return value.map { singleValue in
            if let encodedValue = singleValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                if value.count == 1 {
                    return "\(name)=\(encodedValue)"
                }
                return "\(name)[]=\(encodedValue)"
            }
            return ""
            }.joined(separator: "&")
    }
}
