//
//  FeedStore.swift
//  FeedLoader
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation

protocol FeedStore {
    typealias Completion = (Error?) -> Void
    
    func deleteCache(completion: @escaping Completion)
    func insertCache(with items: [LocalFeedItem], timestamp: Date, completion: @escaping Completion)
}

