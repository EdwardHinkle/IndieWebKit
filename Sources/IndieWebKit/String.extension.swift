//
//  File.swift
//  
//
//  Created by ehinkle-ad on 6/11/19.
//

import Foundation
extension String {
    public static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return randomString(length: length, from: letters)
    }
    
    public static func randomAlphaNumericString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return randomString(length: length, from: letters)
    }
    
    public static func randomString(length: Int, from stringOptions: String) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
