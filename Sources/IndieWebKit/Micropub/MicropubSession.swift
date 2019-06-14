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
        self.accessToken = accessToken
    }
    
    func sendMicropubPost(_ post: MicropubPost, as contentType: MicropubSendType, with action: MicropubActionType? = nil, completion: @escaping ((URL?) -> ())) throws {
        let request = try getMicropubRequest(for: post, as: contentType, with: action)

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            do {
                let postUrl = try self?.parseMicropubResponse(response as? HTTPURLResponse, error: error, with: action)
                // On success we always want to return a url
                // Some actions don't return a url, but if no error is thrown, it was successful
                // So if the url is nil, we use the original post url to indicate success
                // I might need to change this model going forward
                completion(postUrl ?? post.url)
            } catch MicropubError.generalError(let error) {
                print("Error Catching Micropub Request \(error)")
                completion(nil)
            } catch {
                print("Uncaught error")
                completion(nil)
            }
        }.resume()
    }
    
    func getMicropubRequest(for post: MicropubPost, as contentType: MicropubSendType, with action: MicropubActionType? = nil) throws -> URLRequest {
        var request = URLRequest(url: micropubEndpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.addValue("IndieWebKit", forHTTPHeaderField: "X-Powered-By")
        
        var postBody: [String:String] = [:]
        switch action {
        case .some(let activeAction):
            postBody["action"] = activeAction.rawValue
            
            guard post.url != nil else {
                throw MicropubError.generalError("Trying to send Micropub request \(activeAction.rawValue) without a url property")
            }
            
            switch activeAction {
            case .delete:
                postBody["url"] = post.url!.absoluteString
            case .undelete:
                postBody["url"] = post.url!.absoluteString
            }
        default:
            // TODO: Regular Micropub post
            postBody["h"] = "test"
        }
        
        try request.httpBody = JSONEncoder().encode(postBody)
        
        return request
    }
    
    func parseMicropubResponse(_ response: HTTPURLResponse?, error: Error?, with action: MicropubActionType?) throws -> URL? {
        guard error == nil else {
            throw MicropubError.generalError(error!.localizedDescription)
        }

        guard response != nil else {
            throw MicropubError.generalError("URL Response is nil")
        }
        
        guard response!.statusCode != 200 && response!.statusCode != 202 else {
            // TODO: is there a way to get the server's error here?
            throw MicropubError.serverError("Server did not return a success message")
        }
        
        if action == nil, let postUrlString = response!.allHeaderFields["Location"] as? String {
            return URL(string: postUrlString)
        }
        
        return nil
    }
    
    // MARK: Configuration Query
    func getConfigQuery(completion: @escaping ((MicropubConfig?) -> ())) throws {
        let request = try getConfigurationRequest()
        
        URLSession.shared.dataTask(with: request) { [weak self] body, response, error in
            do {
                let config = try self?.parseConfigResponse(body: body, response: response, error: error)
                completion(config)
            } catch MicropubError.generalError(let error) {
                print("Error Catching Config Request \(error)")
                completion(nil)
            } catch {
                print("Uncaught error")
                completion(nil)
            }
        }.resume()
    }
    
    func parseConfigResponse(body: Data?, response: URLResponse?, error: Error?) throws -> MicropubConfig {
        guard body != nil else {
            throw MicropubError.generalError("Micropub Config Request didn't return anything")
        }
        
        guard error == nil else {
            throw MicropubError.generalError(error!.localizedDescription)
        }

        do {
            let config = try JSONDecoder().decode(MicropubConfig.self, from: body!)
            return config
        } catch DecodingError.keyNotFound(let missingKey, _) {
            throw MicropubError.generalError("Micropub Config missing \(missingKey.stringValue) key")
        } catch {
            throw MicropubError.generalError("There was an error trying to decode the server response")
        }
    }
    
    func getConfigurationRequest() throws -> URLRequest {
        guard var configRequestUrl = URLComponents(url: micropubEndpoint, resolvingAgainstBaseURL: false) else {
            throw MicropubError.generalError("Config Query Url Malformed")
        }
        
        configRequestUrl.queryItems = [
            URLQueryItem(name: "q", value: "config")
        ]
        
        var request = URLRequest(url: configRequestUrl.url!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    // MARK: Syndication Target Query
    func getSyndicationTargetQuery(completion: @escaping (([SyndicationTarget]?) -> ())) throws {
        let request = try getSyndicationTargetRequest()
        
        URLSession.shared.dataTask(with: request) { [weak self] body, response, error in
            do {
                let syndicationTargets = try self?.parseSyndicationTargetResponse(body: body, response: response, error: error)
                completion(syndicationTargets)
            } catch MicropubError.generalError(let error) {
                print("Error Catching Syndication Target Request \(error)")
                completion(nil)
            } catch {
                print("Uncaught error")
                completion(nil)
            }
            }.resume()
    }
    
    func parseSyndicationTargetResponse(body: Data?, response: URLResponse?, error: Error?) throws -> [SyndicationTarget] {
        guard body != nil else {
            throw MicropubError.generalError("Micropub Syndication Target Request didn't return anything")
        }
        
        guard error == nil else {
            throw MicropubError.generalError(error!.localizedDescription)
        }
        
        do {
            let config = try JSONDecoder().decode(MicropubConfig.self, from: body!)
            return config.syndicateTo ?? []
        } catch DecodingError.keyNotFound(let missingKey, _) {
            throw MicropubError.generalError("Micropub Config missing \(missingKey.stringValue) key")
        } catch {
            throw MicropubError.generalError("There was an error trying to decode the server response")
        }
    }
    
    func getSyndicationTargetRequest() throws -> URLRequest {
        guard var configRequestUrl = URLComponents(url: micropubEndpoint, resolvingAgainstBaseURL: false) else {
            throw MicropubError.generalError("Config Query Url Malformed")
        }
        
        configRequestUrl.queryItems = [
            URLQueryItem(name: "q", value: MicropubQueryType.syndicateTo.rawValue)
        ]
        
        var request = URLRequest(url: configRequestUrl.url!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
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
