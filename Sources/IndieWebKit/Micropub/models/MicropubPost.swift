//
//  MicropubPost.swift
//  
//
//  Created by ehinkle-ad on 6/14/19.
//

import Foundation
public struct MicropubPost: Encodable {
    var type: MicropubPostType?
    var url: URL?
    var content: String?
    var categories: [String]?
    var externalPhoto: [URL]?
    var externalVideo: [URL]?
    var externalAudio: [URL]?
    var syndicateTo: [SyndicationTarget]?
    
    enum CodingKeys: String, CodingKey {
        case type
        case properties
    }
    
    enum PropertiesKeys: String, CodingKey {
        case url
        case content
        case categories = "category"
        case externalPhoto = "photo"
        case externalVideo = "video"
        case externalAudio = "audio"
        case syndicateTo = "mp-syndicate-to"
    }
    
    public func encode(to encoder: Encoder) throws {
        
        guard type != nil else {
            throw MicropubError.generalError("Missing h-type!")
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(["h-\(type!)"], forKey: .type)
        
        var properties = container.nestedContainer(keyedBy: PropertiesKeys.self, forKey: .properties)
        if url != nil {
            try properties.encode([url], forKey: .url)
        }
        
        if content != nil {
            try properties.encode([content], forKey: .content)
        }
        
        if categories != nil {
            try properties.encode(categories, forKey: .categories)
        }
        
        if externalPhoto != nil {
            try properties.encode(externalPhoto, forKey: .externalPhoto)
        }
        
        if externalVideo != nil {
            try properties.encode(externalVideo, forKey: .externalVideo)
        }
        
        if externalAudio != nil {
            try properties.encode(externalAudio, forKey: .externalAudio)
        }
        
        if syndicateTo != nil {
            try properties.encode(syndicateTo, forKey: .syndicateTo)
        }
    }
    
    public func output(as type: MicropubSendType, with action: MicropubActionType?) throws -> Data? {
        
        switch type {
        case .FormEncoded:
            var postBody: [String] = []
            
            switch action {
            case .some(let activeAction):
                postBody.append(createFormEncodedEntry(name: "action", value: activeAction.rawValue))
                
                guard self.url != nil else {
                    throw MicropubError.generalError("Trying to send Micropub request \(activeAction.rawValue) without a url property")
                }
                
                switch activeAction {
                case .delete: fallthrough
                case .undelete:
                    postBody.append(createFormEncodedEntry(name: "url", value: url!.absoluteString))
                }
            default:
                if self.type != nil {
                    postBody.append(createFormEncodedEntry(name: "h", value: self.type!.rawValue))
                }
                if self.content != nil {
                    postBody.append(createFormEncodedEntry(name: "content", value: content!))
                }
                if self.url != nil {
                    postBody.append(createFormEncodedEntry(name: "url", value: url!.absoluteString))
                }
                if self.categories != nil {
                    postBody.append(createFormEncodedEntry(name: "category", value: categories!))
                }
                if self.externalPhoto != nil {
                    postBody.append(createFormEncodedEntry(name: "photo", value: externalPhoto!.map { $0.absoluteString }))
                }
                if self.externalAudio != nil {
                    postBody.append(createFormEncodedEntry(name: "audio", value: externalAudio!.map { $0.absoluteString }))
                }
                if self.externalVideo != nil {
                    postBody.append(createFormEncodedEntry(name: "video", value: externalVideo!.map { $0.absoluteString }))
                }
                if self.syndicateTo != nil {
                    postBody.append(createFormEncodedEntry(name: "mp-syndicate-to", value: syndicateTo!.map { $0.uid }))
                }
            }
            
            return postBody.joined(separator: "&").data(using: .utf8, allowLossyConversion: false)
        case .Multipart:
            // TODO: Need to build a multipart data function
             return Data()
        case .JSON:
            return try? JSONEncoder().encode(self)
        }
        
    }
    
    func createFormEncodedEntry(name: String, value: String) -> String {
        if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return "\(name)=\(encodedValue)"
        }
        return ""
    }
    
    func createFormEncodedEntry(name: String, value: [String]) -> String {
        return value.map { singleValue in
            if let encodedValue = singleValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                if value.count == 1 {
                    return "\(name)=\(encodedValue)"
                }
                return "\(name)[]=\(encodedValue)"
            }
            return ""
        }.joined(separator: "&")
    }
}
