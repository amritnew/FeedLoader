//
//  FeedStore.swift
//  FeedLoader
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation

enum RetrievalCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

protocol FeedStore {
    typealias Completion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalCachedFeedResult) -> Void
    
    func retrieve(completion: @escaping RetrievalCompletion)
    func deleteCache(completion: @escaping Completion)
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion)
}

