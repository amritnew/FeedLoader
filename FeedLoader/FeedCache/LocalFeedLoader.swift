//
//  LocalFeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation

final class LocalFeedLoader {

    private let store: FeedStore
    private let currentDate: () -> Date
    
    typealias SaveResult = Error?
    typealias LoadResult = LoadFeedResult
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func load(completion: @escaping (LoadResult<Error>) -> Void) {
        store.retrieve { [unowned self] result in
            switch result {
            case .empty, .found:
                completion(.success([]))
            case let .found(feeds, timestamp) where self.validate(timestamp):
                completion(.success(feeds.toModels()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
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
    
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: Date.init()) else {
            return false
        }
        return currentDate() < maxCacheAge
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

