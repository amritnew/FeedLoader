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
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func loadFeed(completion: @escaping ((Error) -> Void)) {
        // call url session to fetch feeds
        //completion([LoadFeedResult()])
        client.get(from: url) { error , response  in
            if let _ = response {
                completion(.invalidData)
            }
            else {
                completion(.connectivity)
            }
        }
    }

}
