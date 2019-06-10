//
//  ProfileDiscoveryRequest.swift
//  
//
//  Created by Edward Hinkle on 6/8/19.
//

import Foundation
import Combine
import SwiftSoup

/// Fetch a user's IndieAuth profile url and discovery endpoints for signing in based how how we want to sign in
///
/// This has to be a class rather than a struct because only classes can be delegates
///
/// Logic follows https://indieauth.spec.indieweb.org/#discovery-by-clients
public class ProfileDiscoveryRequest: NSObject, URLSessionTaskDelegate {
    
    private(set) public var profile: URL
    private(set) public var endpoints: [EndpointType: URL?] = [:]
    
    init(for profile: URL) {
        self.profile = profile
    }
    
    public func start(completion: @escaping (() -> ())) {
        // TODO: Is self being capture below causing a memory leak???
        self.fetchSiteData { response, body in
            self.parseSiteData(response: response, body: body)
            completion()
        }
    }
    
    func parseSiteData(response: HTTPURLResponse, body: String?) {
        if response.allHeaderFields["Link"] != nil {
            let httpLinkHeadersString = response.allHeaderFields["Link"] as! String
            let httpLinkHeaders = httpLinkHeadersString.split(separator: ",")
            httpLinkHeaders.forEach { linkHeader in
                
                // The Link headers are somethign like this: <URL>; rel="<ENDPOINT_TYPE"
                if let endpoint = linkHeader.split(separator: ";") // We split on the semicolon so we can seperate the url
                    .first? // The url is before the semicolon
                    .replacingOccurrences(of: "( |<|>)", with: "", options: .regularExpression), // We want to remove any non-url characters
                    let endpointUrl = URL(string: endpoint, relativeTo: self.profile) {
                    
                    EndpointType.allCases.forEach { endpointType in
                        // Only use value if it is the FIRST instance of a predefined endpointType
                        if self.endpoints[endpointType] == nil && linkHeader.contains("rel=\"\(endpointType)\"") {
                            self.endpoints[endpointType] = endpointUrl
                        }
                    }
                }
            }
        }
        
        // TODO: We should check that the response type is HTML not JSON
        if body != nil {
            do {
                let profilePage: Document = try SwiftSoup.parse(body!)
                
                EndpointType.allCases.filter { self.endpoints[$0] == nil }
                    .forEach { endpointType in
                        
                        if var endpoint = try? profilePage.select("link[rel=\"\(endpointType)\"]").first()?.attr("href") {
                            if !endpoint.contains("http") {
                                endpoint = "\(self.profile)\(endpoint)"
                            }
                            self.endpoints[endpointType] = URL(string: endpoint)
                        }
                }
                
                
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
        }
        
        // TODO: Check if there should be any parsing of values from JSON response types
    }
    
    private func fetchSiteData(completion: @escaping (HTTPURLResponse, String?) -> ()) {
        var request = URLRequest(url: self.profile)
        request.setValue(UAString(), forHTTPHeaderField: "User-Agent")

        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        session.dataTask(with: request) { (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on \(self.profile)")
                print(error ?? "No error present")
                return
            }

            // Check if endpoint is in the HTTP Header fields
            if let httpResponse = response as? HTTPURLResponse {
                var html: String? = nil
                if data != nil {
                    html = String(data: data!, encoding: .utf8)
                }
                
                completion(httpResponse, html)
            }

        }.resume()
    }
    
    public func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        
        // This is a permenant redirect, and we need to track the new url
        if (response.statusCode == 301 || response.statusCode == 308) {
            if request.url != nil {
                profile = request.url!
            }
        }
        
        completionHandler(request)
    }
    
    static public func makeProfileDiscoveryRequest(for profile: URL, completion: @escaping ((ProfileDiscoveryRequest) -> ())) {
        let userDiscoveryRequest = ProfileDiscoveryRequest(for: profile)
        userDiscoveryRequest.start {
            completion(userDiscoveryRequest)
        }
    }
}
