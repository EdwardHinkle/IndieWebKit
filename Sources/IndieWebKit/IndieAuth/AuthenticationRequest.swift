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
    
    private var url: URL? {
        var requestUrl = URLComponents(url: authorizationEndpoint, resolvingAgainstBaseURL: false)
        requestUrl?.queryItems?.append(URLQueryItem(name: "me", value: profile.absoluteString))
        requestUrl?.queryItems?.append(URLQueryItem(name: "client_id", value: clientId.absoluteString))
        requestUrl?.queryItems?.append(URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString))
        requestUrl?.queryItems?.append(URLQueryItem(name: "state", value: state))
        
        if codeChallenge != nil {
            requestUrl?.queryItems?.append(URLQueryItem(name: "code_challenge", value: codeChallenge))
            requestUrl?.queryItems?.append(URLQueryItem(name: "code_challenge_method", value: codeChallengeMethod))
        }
        
        return requestUrl?.url
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
    
    func start(completion: @escaping ((String?) -> ())) {
        guard url != nil else {
            // TODO: Throw some type of error
            return
        }
        
        ASWebAuthenticationSession(url: url!, callbackURLScheme: nil) { [weak self] responseUrl, error in
            guard error == nil else {
                // TODO: Throw some type of error
                return
            }
            
            guard responseUrl != nil else {
                // TODO: Throw some type of error
                return
            }
            
            let authorizationCode = self?.parseResponse(responseUrl!)
            guard authorizationCode != nil else {
                // TODO: Throw an error because authorization code should not be nil
                return
            }
            
            verifyAuthenticationCode(authorizationCode!)
        }.start()
    }
    
    private func parseResponse(_ responseUrl: URL) -> String {
        let responseComponents = URLComponents(url: responseUrl, resolvingAgainstBaseURL: false)
        var state = ""
        var code = ""
        
        responseComponents?.queryItems?.forEach { queryItem in
            if queryItem.name == "code", queryItem.value != nil {
                code = queryItem.value!
            } else if queryItem.name == "state", queryItem.value != nil {
                state = queryItem.value!
            }
        }
    
        guard state == self.state else {
            // TODO: Throw some error because state doesn't match
            return ""
        }
        
        return code
    }
    
    private func verifyAuthenticationCode(_ code: String) {
        // TODO: Resume #5 here
    }
    
    private func generateDefaultCodeChallenge() -> String? {
        return Data(base64Encoded: randomString(length: 128).sha256())?.base64EncodedString()
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
