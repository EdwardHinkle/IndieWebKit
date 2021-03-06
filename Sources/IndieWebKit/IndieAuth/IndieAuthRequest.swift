//
//  IndieAuthRequest.swift
//  
//
//  Created by ehinkle-ad on 6/11/19.
//

import Foundation
import CryptoSwift
//import AuthenticationServices

public class IndieAuthRequest {
 
    private var responseType: AccessType
    private(set) internal var profile: URL
    private var authorizationEndpoint: URL
    private var tokenEndpoint: URL?
    private var clientId: URL
    private var redirectUri: URL
    private var state: String
    private(set) internal var scope: [String]
    private var codeChallenge: String?
    private let codeChallengeMethod = "S256"
    
    var url: URL? {
        var requestUrl = URLComponents(url: authorizationEndpoint, resolvingAgainstBaseURL: false)
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "me", value: profile.absoluteString))
        queryItems.append(URLQueryItem(name: "client_id", value: clientId.absoluteString))
        queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString))
        queryItems.append(URLQueryItem(name: "state", value: state))
        
        if scope.count > 0 {
            queryItems.append(URLQueryItem(name: "scope", value: scope.joined(separator: " ")))
        }
        
        queryItems.append(URLQueryItem(name: "response_type", value: responseType.rawValue))
        
        if codeChallenge != nil {
            queryItems.append(URLQueryItem(name: "code_challenge_method", value: codeChallengeMethod))
            queryItems.append(URLQueryItem(name: "code_challenge", value: codeChallenge))
        }
        
        requestUrl?.queryItems = queryItems
        
        return requestUrl?.url
    }
    
    
    init(_ responseType: AccessType,
         for profile: URL,
         at authorizationEndpoint: URL,
         with tokenEndpoint: URL? = nil,
         clientId: URL,
         redirectUri: URL,
         state: String,
         scope: [String] = [],
         codeChallenge: String? = nil) {
        
            self.responseType = responseType
            self.profile = profile
            self.authorizationEndpoint = authorizationEndpoint
            self.tokenEndpoint = tokenEndpoint
            self.clientId = clientId
            self.redirectUri = redirectUri
            self.state = state
            self.scope = scope
            self.codeChallenge = codeChallenge
        
            if self.codeChallenge == nil {
                self.codeChallenge = generateDefaultCodeChallenge()
            }
    }
    
    @available(iOS 12.0, macOS 10.15, *)
    func start(completion: @escaping ((URL?) -> ())) {
        guard url != nil else {
            // TODO: Throw some type of error
            return
        }
        
//        ASWebAuthenticationSession(url: url!, callbackURLScheme: nil) { [weak self] responseUrl, error in
//            guard error == nil else {
//                // TODO: Throw some type of error
//                return
//            }
//
//            guard responseUrl != nil else {
//                // TODO: Throw some type of error
//                return
//            }
//
//            let authorizationCode = self?.parseResponse(responseUrl!)
//            guard authorizationCode != nil else {
//                // TODO: Throw an error because authorization code should not be nil
//                return
//            }
//
//            switch (self?.responseType) {
//            case .Authentication:
//                self?.verifyAuthenticationCode(authorizationCode!) { [weak self] codeVerified in
//                    if (codeVerified) {
//                        completion(self?.profile)
//                    } else {
//                        completion(nil)
//                    }
//                }
//            case .Authorization:
//                self?.retrieveToken(authorizationCode!) { [weak self] token in
//                    if (token != nil) {
//                        completion(nil) // Need to figure out what to return
//                    } else {
//                        completion(nil)
//                    }
//                }
//            case .none:
//                // TODO: ERROR!
//                print("ERROR!! No Response Type")
//            }
//
//        }.start()
    }
    
    func parseResponse(_ responseUrl: URL) -> String {
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
    
    func verifyAuthenticationCode(_ code: String, completion: @escaping ((Bool) -> Void)) {
        
        do {
            let verificationRequest = try getVerificationRequest(with: code)
            
            URLSession.shared.dataTask(with: verificationRequest) { [weak self] body, response, error in
                guard error == nil else {
                    // TODO: Throw error here
                    return
                }
                
                // TODO: Check to make sure content type is application/json
                
                guard body != nil else {
                    // TODO: throw error here
                    return
                }
                
                let responseProfile = try! JSONDecoder().decode([String:URL].self, from: body!)
                
                completion(self!.confirmVerificationResponse(responseProfile))
                
                }.resume()
            
        } catch {
            // TODO: Figure out how to report error
            completion(false)
        }
    }
    
    func retrieveToken(_ code: String, completion: @escaping ((String?) -> Void)) {
        
//        do {
//            let verificationRequest = try getTokenRequest(with: code)
//
//            URLSession.shared.dataTask(with: verificationRequest) { [weak self] body, response, error in
//                guard error == nil else {
//                    // TODO: Throw error here
//                    return
//                }
//
//                // TODO: Check to make sure content type is application/json
//
//                guard body != nil else {
//                    // TODO: throw error here
//                    return
//                }
//
//                let response = try! JSONDecoder().decode([String:URL].self, from: body!)
//
//                completion(self!.confirmVerificationResponse(response))
//
//                }.resume()
//
//        } catch {
//            // TODO: Figure out how to report error
//            completion(false)
//        }
    }
    
    func getVerificationRequest(with code: String) throws -> URLRequest {
        var request = URLRequest(url: authorizationEndpoint)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var postBody = [
            "code": code,
            "client_id": clientId.absoluteString,
            "redirect_uri": redirectUri.absoluteString
        ]
        
        if codeChallenge != nil {
            postBody["code_verifier"] = codeChallenge
        }
        
        try request.httpBody = JSONEncoder().encode(postBody)
        
        return request
    }
    
    func getTokenRequest(with code: String) throws -> URLRequest {
        guard tokenEndpoint != nil else {
            // TODO: Throw error!
            throw URLError(URLError.Code.badURL)
        }
        
        var request = URLRequest(url: tokenEndpoint!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var postBody = [
            "grant_type": "authorization_code",
            "code": code,
            "client_id": clientId.absoluteString,
            "redirect_uri": redirectUri.absoluteString,
            "me": profile.absoluteString
        ]
        
        if codeChallenge != nil {
            postBody["code_verifier"] = codeChallenge
        }
        
        try request.httpBody = JSONEncoder().encode(postBody)
        
        return request
    }
    
    func confirmVerificationResponse(_ responseProfile: [String:URL]) -> Bool {
        guard responseProfile["me"] != nil else {
            return false
        }
        
        let meComponents = URLComponents(url: responseProfile["me"]!, resolvingAgainstBaseURL: false)
        let profileComponents = URLComponents(url: profile, resolvingAgainstBaseURL: false)
        
        let validProfile = meComponents?.host == profileComponents?.host
        
        if (validProfile) {
            profile = responseProfile["me"]!
        }
        
        return validProfile
    }
    
    func parseTokenResponse(_ response: Data) throws -> (String, String) {
        
        let responseDictionary = try! JSONDecoder().decode([String:String].self, from: response)
        
        guard responseDictionary["access_token"] != nil else {
            // TODO: throw error
            throw IndieAuthError.authorizationError("Missing access_token in Response")
        }
        
        guard responseDictionary["token_type"] != nil else {
            // TODO: throw error
            throw IndieAuthError.authorizationError("Missing token_type in Response")
        }
        
        guard responseDictionary["scope"] != nil else {
            // TODO: throw error
            throw IndieAuthError.authorizationError("Missing scope in Response")
        }
        
        guard responseDictionary["me"] != nil else {
            // TODO: throw error
            throw IndieAuthError.authorizationError("Missing me in Response")
        }
        
        guard let meUrl = URL(string: responseDictionary["me"]!) else {
            throw IndieAuthError.authorizationError("me isn't a value url")
        }
        
        guard meUrl.host == profile.host else {
            throw IndieAuthError.authorizationError("me is a different domain than original")
        }
        
        scope = responseDictionary["scope"]!.components(separatedBy: " ")
        
        guard scope.count > 0 else {
            throw IndieAuthError.authorizationError("no scopes returned")
        }
        
        // TODO: We need to make sure the profile breaks for spoofing
        profile = meUrl

        return (responseDictionary["token_type"]!, responseDictionary["access_token"]!)
    }
    
    private func generateDefaultCodeChallenge() -> String? {
        return Data(base64Encoded: String.randomString(length: 128).sha256())?.base64EncodedString()
    }
    
    func checkCodeChallenge(_ testChallenge: String) -> Bool {
        guard codeChallenge != nil else {
            return false
        }
        
        return codeChallenge! == testChallenge
    }
    
    public static func revokeToken(_ accessToken: String, for tokenEndpoint: URL, completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: tokenEndpoint)
        request.httpMethod = "POST"
        request.addValue(MicropubSendType.FormEncoded.rawValue, forHTTPHeaderField: "Content-Type")
        request.addValue(MicropubSendType.JSON.rawValue, forHTTPHeaderField: "Accept")
        request.httpBody = "action=revoke&token=\(accessToken)".data(using: .utf8, allowLossyConversion: false)
        
        URLSession.shared.dataTask(with: request) { body, response, error in
            guard error == nil else {
                // TODO: Add error
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // TODO: Add error
                completion(false)
                return
            }
            
            completion(httpResponse.statusCode == 200)
        }
    }
}
