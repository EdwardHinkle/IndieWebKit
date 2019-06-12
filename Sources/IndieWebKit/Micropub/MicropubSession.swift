//
//  MicropubSession.swift
//  
//
//  Created by ehinkle-ad on 6/12/19.
//

import Foundation

public class MicropubSession {
    
    private var micropubEndpoint: URL
    private var accessToken: String
    
    init(to micropubEndpoint: URL,
         with accessToken: String) {
        
        self.micropubEndpoint = micropubEndpoint
    }
    
    func start(completion: @escaping ((URL?) -> ())) {
        guard url != nil else {
            // TODO: Throw some type of error
            return
        }
    
    }
    
    
   
//    func getVerificationRequest(with code: String) throws -> URLRequest {
//        var request = URLRequest(url: authorizationEndpoint)
//        request.httpMethod = "POST"
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        var postBody = [
//            "code": code,
//            "client_id": clientId.absoluteString,
//            "redirect_uri": redirectUri.absoluteString
//        ]
//
//        if codeChallenge != nil {
//            postBody["code_verifier"] = codeChallenge
//        }
//
//        try request.httpBody = JSONEncoder().encode(postBody)
//
//        return request
//    }
    
//    func getTokenRequest(with code: String) throws -> URLRequest {
//        guard tokenEndpoint != nil else {
//            // TODO: Throw error!
//            throw URLError(URLError.Code.badURL)
//        }
//
//        var request = URLRequest(url: tokenEndpoint!)
//        request.httpMethod = "POST"
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        var postBody = [
//            "grant_type": "authorization_code",
//            "code": code,
//            "client_id": clientId.absoluteString,
//            "redirect_uri": redirectUri.absoluteString,
//            "me": profile.absoluteString
//        ]
//
//        if codeChallenge != nil {
//            postBody["code_verifier"] = codeChallenge
//        }
//
//        try request.httpBody = JSONEncoder().encode(postBody)
//
//        return request
//    }
    
//    func parseTokenResponse(_ response: Data) throws -> (String, String) {
//
//        let responseDictionary = try! JSONDecoder().decode([String:String].self, from: response)
//
//        guard responseDictionary["access_token"] != nil else {
//            // TODO: throw error
//            throw IndieAuthError.authorizationError("Missing access_token in Response")
//        }
//
//        guard responseDictionary["token_type"] != nil else {
//            // TODO: throw error
//            throw IndieAuthError.authorizationError("Missing token_type in Response")
//        }
//
//        guard responseDictionary["scope"] != nil else {
//            // TODO: throw error
//            throw IndieAuthError.authorizationError("Missing scope in Response")
//        }
//
//        guard responseDictionary["me"] != nil else {
//            // TODO: throw error
//            throw IndieAuthError.authorizationError("Missing me in Response")
//        }
//
//        guard let meUrl = URL(string: responseDictionary["me"]!) else {
//            throw IndieAuthError.authorizationError("me isn't a value url")
//        }
//
//        guard meUrl.host == profile.host else {
//            throw IndieAuthError.authorizationError("me is a different domain than original")
//        }
//
//        scope = responseDictionary["scope"]!.components(separatedBy: " ")
//
//        guard scope.count > 0 else {
//            throw IndieAuthError.authorizationError("no scopes returned")
//        }
//
//        // TODO: We need to make sure the profile breaks for spoofing
//        profile = meUrl
//
//        return (responseDictionary["token_type"]!, responseDictionary["access_token"]!)
//    }
}
