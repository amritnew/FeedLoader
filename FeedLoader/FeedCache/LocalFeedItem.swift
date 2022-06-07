//
//  LocalFeedItem.swift
//  FeedLoader
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation

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
