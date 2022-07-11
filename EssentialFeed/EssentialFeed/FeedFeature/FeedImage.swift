//
//  FeedItem.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation

struct FeedImage: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
    
    init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}


