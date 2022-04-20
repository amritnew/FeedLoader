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
            case let .success(data, _):
                if let _ = try? JSONSerialization.jsonObject(with: data) {
                    completion(.success([]))
                }
                else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }

}
