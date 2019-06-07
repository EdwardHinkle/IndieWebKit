//
//  IndieAuth.swift
//  
//
//  Created by Eddie Hinkle on 6/7/19.
//

import Foundation
import Network

public class IndieAuth {
    
    /// Convienance method to check if a given string is a valid IndieAuth profile
    /// - Parameter string: a string representation of an IndieAuth url profile
    static public func isValidProfile(string: String) -> Bool {
        
        guard let url = URL(string: string) else {
            // An IndieAuth profile is not valid if it's not a url
            return false;
        }

        return IndieAuth.isValidProfile(url: url);
    }
    
    /// Checks if a given url is valid for the purpose of representing an IndieAuth profile
    /// Logic for a valid profile comes from ths spec here: https://indieauth.spec.indieweb.org/#user-profile-url
    /// - Parameter url: an IndieAuth profile url
    static public func isValidProfile(url: URL) -> Bool {
        // If the url is so badly formed it can't be turned into components, it definitely isn't valid
        guard let urlComp = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false;
        }
        
        // Profile URLs MUST have either an https or http scheme
        guard urlComp.scheme != nil && (urlComp.scheme == "http" || urlComp.scheme == "https") else {
            return false;
        }
        
        // MUST contain a path component (/ is a valid path),
        guard urlComp.path != "" else {
            return false;
        }
        
        // MUST NOT contain single-dot or double-dot path segments
        guard !urlComp.path.contains(".") && !urlComp.path.contains("..") else {
            return false;
        }
        
        // MAY contain a query string component
        // I don't think we need to do anything special to check this
        
        // MUST NOT contain a fragment component
        guard urlComp.fragment == nil else {
            return false;
        }
        
        // MUST NOT contain a username or password component
        guard urlComp.user == nil && urlComp.password == nil else {
            return false;
        }
        
        // MUST NOT contain a port.
        guard urlComp.port == nil else {
            return false;
        }
        
        // Additionally, hostnames MUST be domain names and MUST NOT be ipv4 or ipv6 addresses.
        if #available(OSX 10.14, *) {
            guard let hostname = urlComp.host else {
                return false;
            }
            
            guard IPv4Address(hostname) == nil || hostname == "127.0.0.1" else {
                return false;
            }
            
            guard IPv6Address(hostname) == nil || hostname == "[::1]" else {
                return false;
            }
        }
        
        // If we made it here, we must have a legit profile! 🙌
        return true;
    }
    
    /// Convienance method to normalize a given string and convert it into a Url for use as an IndieAuth Profile
    /// - Parameter string: a string representation of an IndieAuth url profile
//    static public func normalizeProfileUrl(string: String) -> URL? {
//
//        guard let url = URL(string: string) else {
//            // An IndieAuth profile is not valid if it's not a url
//            return nil;
//        }
//
//        return IndieAuth.normalizeProfileUrl(url: url);
//    }
    
    /// Normalize the profile url based on IndieAuth spec
    /// https://indieauth.spec.indieweb.org/#url-canonicalization
    /// - Parameter url: an IndieAuth profile url
//    static public func normalizeProfileUrl(url: URL) -> URL? {
//        guard let originalUrl = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
//            return nil;
//        }
//
//        var normalizedUrl = URLComponents()
//
//        normalizedUrl.host = originalUrl.host
//        normalizedUrl.query = originalUrl.query
//
//        // If no scheme exists, add http
//        if originalUrl.scheme == nil {
//            normalizedUrl.scheme = "http"
//        } else {
//            normalizedUrl.scheme = originalUrl.scheme
//        }
//
//        if originalUrl.path {
//            normalizedUrl.path = originalUrl.path
//        } else {
//            normalizedUrl.path = "/"
//        }
//
//        // If path is empty, we append / as the path
////        if originalUrl.path || originalUrl.path == "" {
////            normalizedUrl.path = "/"
////        } else {
////            normalizedUrl.path = originalUrl.path
////        }
//
//        return normalizedUrl.url
//    }
    
//    static public func discoverProfileEndpoints(url: URL) -> void {
//        // TODO: Follow https://indieauth.spec.indieweb.org/#discovery-by-clients
//    }
    
}
