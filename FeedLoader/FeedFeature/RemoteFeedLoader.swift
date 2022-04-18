//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation


class RemoteFeedLoader: FeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func loadFeed(completion: @escaping ((LoadFeedResult) -> Void)) {
        // call url session to fetch feeds
        //completion([LoadFeedResult()])
        client.get(from: url)
    }

}
