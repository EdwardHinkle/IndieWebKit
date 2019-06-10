//
//  AuthenticationRequest.swift
//  
//
//  Created by ehinkle-ad on 6/10/19.
//

import Foundation
import CryptoSwift
import AuthenticationServices

public class AuthenticationRequest {
    
    private var profile: URL
    private var authorizationEndpoint: URL
    private var clientId: URL
    private var redirectUri: URL
    private var state: String
    private var codeChallenge: String?
    private let codeChallengeMethod = "S256"
    
    private var url: URL {
        var requestUrl = URLComponents(url: authorizationEndpoint, resolvingAgainstBaseURL: false)
        requestUrl?.queryItems.push(URLQueryItem(name: "me", value: profile))
        requestUrl?.queryItems.push(URLQueryItem(name: "client_id", value: clientId))
        requestUrl?.queryItems.push(URLQueryItem(name: "redirect_uri", value: redirectUri))
        requestUrl?.queryItems.push(URLQueryItem(name: "state", value: state))
        
        if codeChallenge != nil {
            requestUrl?.queryItems.push(URLQueryItem(name: "code_challenge", value: codeChallenge))
            requestUrl?.queryItems.push(URLQueryItem(name: "code_challenge_method", value: codeChallengeMethod))
        }
        
        return requestUrl.url
    }
    
    init(for profile: URL, at authorizationEndpoint: URL, clientId: URL, redirectUri: URL, state: String, codeChallenge: String?) {
        self.profile = profile
        self.authorizationEndpoint = authorizationEndpoint
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.state = state
        self.codeChallenge = codeChallenge
        
        if self.codeChallenge == nil {
            self.codeChallenge = generateDefaultCodeChallenge()
        }
    }
    
    func start() {
        ASWebAuthenticationSession(url: url, callbackURLScheme: <#T##String?#>, completionHandler: <#T##ASWebAuthenticationSession.CompletionHandler##ASWebAuthenticationSession.CompletionHandler##(URL?, Error?) -> Void#>)
    }
    
    private func generateDefaultCodeChallenge() -> String? {
        return Data(base64Encoded: randomString(length: 128).sha256())?.base64EncodedString()
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
