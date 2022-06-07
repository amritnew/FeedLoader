//
//  FeedItemMapper.swift
//  FeedLoader
//
//  Created by AmritPandey on 27/04/22.
//

import Foundation

struct RemoteFeedItem: Equatable, Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static var OK_200: Int {
        return 200
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws  -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
