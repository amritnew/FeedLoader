//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 15/04/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping ((LoadFeedResult) -> Void))
}
