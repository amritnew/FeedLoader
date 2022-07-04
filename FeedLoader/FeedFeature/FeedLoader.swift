//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 15/04/22.
//

import Foundation

typealias LoadFeedResult = Result<[FeedImage], Error>

protocol FeedLoader {
    func load(completion: @escaping ((LoadFeedResult) -> Void))
}
