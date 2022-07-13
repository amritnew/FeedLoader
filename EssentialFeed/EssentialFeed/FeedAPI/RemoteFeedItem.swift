//
//  RemoteFeedItem.swift
//  FeedLoader
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation

struct RemoteFeedItem: Equatable, Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
