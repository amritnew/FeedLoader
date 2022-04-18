//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 15/04/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping ((LoadFeedResult) -> Void))
}
