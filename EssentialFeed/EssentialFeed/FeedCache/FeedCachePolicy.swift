//
//  FeedCachePolicy.swift
//  FeedLoader
//
//  Created by AmritPandey on 10/06/22.
//

import Foundation

final class FeedCachePolicy {
    private init() {}
    
    private static let maxCacheAgeInDays = 7
    private static let calendar = Calendar(identifier: .gregorian)
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
