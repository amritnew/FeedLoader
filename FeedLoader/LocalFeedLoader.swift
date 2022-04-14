//
//  LocalFeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation

class LocalFeedLoader: FeedLoader {
    func loadFeed(completion: @escaping (([String]) -> Void)) {
        //get feeds from cache
        completion(["A", "B"])
    }
}
