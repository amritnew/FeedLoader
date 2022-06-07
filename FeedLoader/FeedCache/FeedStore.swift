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

struct LocalFeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
    
    init(id: UUID, description: String?, location: String?, imageUrl: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
}
