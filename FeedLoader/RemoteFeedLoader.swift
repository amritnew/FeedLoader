//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation


class RemoteFeedLoader: FeedLoader {
    
    func loadFeed(completion: @escaping (([String]) -> Void)) {
        // call url session to fetch feeds
        completion(["A", "B"])
    }

}
