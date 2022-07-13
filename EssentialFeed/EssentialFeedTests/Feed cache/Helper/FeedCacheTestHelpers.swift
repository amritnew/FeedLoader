//
//  FeedCacheTestHelpers.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 09/06/22.
//

import Foundation
@testable import EssentialFeed

func uniqueItem() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyUrl())
}

func uniqueImageFeed() -> (models: [FeedImage], localModels: [LocalFeedImage]) {
    let items = [uniqueItem(), uniqueItem()]
    let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.url) }
    return(items, localItems)
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}

