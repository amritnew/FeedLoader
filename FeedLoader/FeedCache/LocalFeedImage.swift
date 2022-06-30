//
//  LocalFeedImage.swift
//  FeedLoader
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation

struct LocalFeedImage: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
    
    init(id: UUID, description: String?, location: String?, imageUrl: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = imageUrl
    }
}


