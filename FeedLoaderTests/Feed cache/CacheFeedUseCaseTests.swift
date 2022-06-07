//
//  CacheFeedUseCaseTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation
import XCTest

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    var deleteCacheCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesnotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }
}
