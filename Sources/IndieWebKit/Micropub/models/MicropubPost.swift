//
//  MicropubPost.swift
//  
//
//  Created by ehinkle-ad on 6/14/19.
//

import Foundation
public struct MicropubPost: Codable {
    var type: MicropubPostType?
    var url: URL?
    var content: String?
    var htmlContent: String? // Requires JSON
    var categories: [String]?
    var externalPhoto: [ExternalFile]?
    var externalVideo: [ExternalFile]?
    var externalAudio: [ExternalFile]?
    var syndicateTo: [SyndicationTarget]?
    var visibility: MicropubVisibility?
    
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
        case visibility
    }
    
    public init(type: MicropubPostType?,
                visibility: MicropubVisibility? = MicropubVisibility.open,
                url: URL? = nil,
                content: String? = nil,
                htmlContent: String? = nil,
                categories: [String]? = nil,
                externalPhoto: [ExternalFile]? = nil,
                externalVideo: [ExternalFile]? = nil,
                externalAudio: [ExternalFile]? = nil,
                syndicateTo: [SyndicationTarget]? = nil) {
        
        self.type = type
        self.visibility = visibility
        self.url = url
        self.content = content
        self.htmlContent = htmlContent
        self.categories = categories
        self.externalPhoto = externalPhoto
        self.externalVideo = externalVideo
        self.externalAudio = externalAudio
        self.syndicateTo = syndicateTo
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode([MicropubPostType].self, forKey: .type)[0]
        
        //        guard type != nil else {
        //            throw MicropubError.generalError("Missing h-type!")
        //        }
        //
        //        var container = encoder.container(keyedBy: CodingKeys.self)
        //        try container.encode(["h-\(type!)"], forKey: .type)
        //
        //        var properties = container.nestedContainer(keyedBy: PropertiesKeys.self, forKey: .properties)
        //        if url != nil {
        //            try properties.encode([url], forKey: .url)
        //        }
        //
        //        if htmlContent != nil {
        //            try properties.encode([["html": htmlContent!]], forKey: .content)
        //        } else if content != nil {
        //            try properties.encode([content], forKey: .content)
        //        }
        //
        //        if categories != nil {
        //            try properties.encode(categories, forKey: .categories)
        //        }
        //
        //        if externalPhoto != nil {
        //            try properties.encode(externalPhoto, forKey: .externalPhoto)
        //        }
        //
        //        if externalVideo != nil {
        //            try properties.encode(externalVideo, forKey: .externalVideo)
        //        }
        //
        //        if externalAudio != nil {
        //            try properties.encode(externalAudio, forKey: .externalAudio)
        //        }
        //
        //        if syndicateTo != nil {
        //            try properties.encode(syndicateTo, forKey: .syndicateTo)
        //        }
        //
        //        if visibility != nil {
        //            try properties.encode(visibility, forKey: .visibility)
        //        }
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
        
        if htmlContent != nil {
            try properties.encode([["html": htmlContent!]], forKey: .content)
        } else if content != nil {
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
        
        if visibility != nil {
            try properties.encode(visibility, forKey: .visibility)
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
                    postBody.append(createFormEncodedEntry(name: PropertiesKeys.url.rawValue, value: url!.absoluteString))
                }
            default:
                if self.type != nil {
                    // The name on this item has to be a string of "h" because the CodingKey is the json version ("type")
                    postBody.append(createFormEncodedEntry(name: "h", value: self.type!.rawValue))
                }
                if self.content != nil {
                    postBody.append(createFormEncodedEntry(name: PropertiesKeys.content.rawValue, value: content!))
                }
                if self.url != nil {
                    postBody.append(createFormEncodedEntry(name: PropertiesKeys.url.rawValue, value: url!.absoluteString))
                }
                if self.categories != nil {
                    postBody.append(createFormEncodedEntry(name: PropertiesKeys.categories.rawValue, value: categories!))
                }
                if self.externalPhoto != nil {
                    postBody.append(createFormEncodedEntry(name: PropertiesKeys.externalPhoto.rawValue, value: externalPhoto!.map { $0.value.absoluteString }))
                }
                if self.externalAudio != nil {
                    postBody.append(createFormEncodedEntry(name: PropertiesKeys.externalAudio.rawValue, value: externalAudio!.map { $0.value.absoluteString }))
                }
                if self.externalVideo != nil {
                    postBody.append(createFormEncodedEntry(name: PropertiesKeys.externalVideo.rawValue, value: externalVideo!.map { $0.value.absoluteString }))
                }
                if self.syndicateTo != nil {
                    postBody.append(createFormEncodedEntry(name: PropertiesKeys.syndicateTo.rawValue, value: syndicateTo!.map { $0.uid }))
                }
                if self.visibility != nil {
                    postBody.append(createFormEncodedEntry(name: PropertiesKeys.visibility.rawValue, value: visibility!.rawValue))
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
