//
//  IndieAuth.swift
//  
//
//  Created by Eddie Hinkle on 6/7/19.
//

import Foundation

public class IndieAuth {
    
    static public func isValidProfile(string: String) -> Bool {
        let urlOfString = URL(string: string);
        
        guard let url = urlOfString else {
            return false;
        }

        return IndieAuth.isValidProfile(url: url);
    }
    
    static public func isValidProfile(url: URL) -> Bool {
        return false;
        
        
        
        
        // Profile URLs MUST have either an https or http scheme
        // MUST contain a path component (/ is a valid path),
        // MUST NOT contain single-dot or double-dot path segments
        // MAY contain a query string component
        // MUST NOT contain a fragment component
        // MUST NOT contain a username or password component
        // MUST NOT contain a port.
        // Additionally, hostnames MUST be domain names and MUST NOT be ipv4 or ipv6 addresses.
        //
        //        Some examples of valid profile URLs are:
        //
        //        https://example.com/
        //        https://example.com/username
        //        https://example.com/users?id=100
        //        Some examples of invalid profile URLs are:
        //
        //        example.com - missing scheme
        //        mailto:user@example.com - invalid scheme
        //        https://example.com/foo/../bar - contains a double-dot path segment
        //        https://example.com/#me - contains a fragment
        //        https://user:pass@example.com/ - contains a username and password
        //        https://example.com:8443/ - contains a port
        //        https://172.28.92.51/ - host is an IP address
    }
    
}
