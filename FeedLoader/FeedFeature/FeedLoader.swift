//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 15/04/22.
//

import Foundation

enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func loadFeed(completion: @escaping ((LoadFeedResult<Error>) -> Void))
}
