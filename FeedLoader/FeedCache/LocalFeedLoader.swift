//
//  LocalFeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation

private final class FeedCachePolicy {
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

final class LocalFeedLoader {

    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
}
 
extension LocalFeedLoader: FeedLoader {
    typealias LoadResult = LoadFeedResult
    
    func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .found(feeds, timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feeds.toModels()))
                
            case let .failure(error):
                completion(.failure(error))
            case .empty, .found:
                completion(.success([]))
            }
        }
    }
}
 
extension LocalFeedLoader {
    func validate() {
        store.retrieve{ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCache {_ in }
            case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCache {_ in }
            case .empty, .found:
                break
            }
        }
        
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
    func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCache { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            }
            else {
                self.cacheItem(items, with: completion)
            }
        }
    }
    
    private func cacheItem(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insertCache(with: items.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
    
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}

