//
//  FeedStore.swift
//  FeedLoader
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation

protocol FeedStore {
    typealias Completion = (Error?) -> Void
    
    func retrieve()
    func deleteCache(completion: @escaping Completion)
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion)
}

