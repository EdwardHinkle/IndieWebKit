//
//  ProfileDiscoveryRequest.swift
//  
//
//  Created by Edward Hinkle on 6/8/19.
//

import Foundation

/// Fetch a user's IndieAuth profile url and discovery endpoints for signing in based how how we want to sign in
///
/// This has to be a class rather than a struct because only classes can be delegates
///
/// Logic follows https://indieauth.spec.indieweb.org/#discovery-by-clients
public class ProfileDiscoveryRequest: NSObject, URLSessionTaskDelegate {
    
    private(set) public var profile: URL
    private(set) public var endpoints: ProfileEndpoints?
    
    init(for profile: URL) {
        self.profile = profile
        endpoints = nil
    }
    
    public func start(completion: @escaping (() -> ())) {
        self.fetchSiteData { response, html in
            
            self.endpoints = ProfileEndpoints()
            
            if response.allHeaderFields["Link"] != nil {
                let httpLinkHeadersString = response.allHeaderFields["Link"] as! String
                let httpLinkHeaders = httpLinkHeadersString.split(separator: ",")
                httpLinkHeaders.forEach { linkHeader in
                    
                    // The Link headers are somethign like this: <URL>; rel="<ENDPOINT_TYPE"
                    if let endpoint = linkHeader.split(separator: ";") // We split on the semicolon so we can seperate the url
                                            .first? // The url is before the semicolon
                                            .replacingOccurrences(of: "( |<|>)", with: "", options: .regularExpression), // We want to remove any non-url characters
                        let endpointUrl = URL(string: endpoint) {
                        
                            if linkHeader.contains("rel=\"authorization_endpoint\"") {
                                self.endpoints?.authorization_endpoint = endpointUrl
                            }
                            if linkHeader.contains("rel=\"token_endpoint\"") {
                                self.endpoints?.token_endpoint = endpointUrl
                            }
                            if linkHeader.contains("rel=\"micropub\"") {
                                self.endpoints?.micropub_endpoint = endpointUrl
                            }
                            if linkHeader.contains("rel=\"microsub\"") {
                                self.endpoints?.microsub_endpoint = endpointUrl
                            }
                            if linkHeader.contains("rel=\"webmention\"") {
                                self.endpoints?.webmention_endpoint = endpointUrl
                            }
                        
                    }
                }
            }
            
            // TODO: Check html for rel-links
            
            completion()
        }
    }
    
    private func fetchSiteData(completion: @escaping ((HTTPURLResponse, Data?)) -> ()) {
        var request = URLRequest(url: self.profile)
        request.setValue(UAString(), forHTTPHeaderField: "User-Agent")

        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        let task = session.dataTask(with: request) { (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on \(self.profile)")
                print(error ?? "No error present")
                return
            }

            // Check if endpoint is in the HTTP Header fields
            if let httpResponse = response as? HTTPURLResponse {
                completion((httpResponse, data))
            }

        }

        task.resume()

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
