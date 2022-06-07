//
//  LocalFeedLoader.swift
//  FeedLoader
//
//  Created by AmritPandey on 14/04/22.
//

import Foundation

class LocalFeedLoader {

    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCache { [weak self] error in
            guard let self = self else { return }
            if (error == nil) {
                self.store.insertCache(with: items, timestamp: self.currentDate()) { [weak self] error in
                    guard let self = self else { return }
                    completion(error)
                }
            }
            else {
                completion(error)
            }
        }
    }
}
