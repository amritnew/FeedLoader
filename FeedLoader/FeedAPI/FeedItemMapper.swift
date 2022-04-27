//
//  FeedItemMapper.swift
//  FeedLoader
//
//  Created by AmritPandey on 27/04/22.
//

import Foundation


final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Equatable, Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
        
    }
    
    static var OK_200: Int {
        return 200
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
    }
}
