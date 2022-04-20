//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation


class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func loadFeed(completion: @escaping (Result) -> Void) {
        // call url session to fetch feeds
        //completion([LoadFeedResult()])
        client.get(from: url) { result  in
            switch result {
            case let .success(data, response):
                do{
                    let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items))
                }
                catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }

}

private class FeedItemsMapper {
    
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


