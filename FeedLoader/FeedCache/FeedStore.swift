//
//  FeedStore.swift
//  FeedLoader
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation

protocol FeedStore {
    typealias Completion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void
    
    func retrieve(completion: @escaping RetrievalCompletion)
    func deleteCache(completion: @escaping Completion)
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion)
}

