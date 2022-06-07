//
//  CacheFeedUseCaseTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation
import XCTest
@testable import FeedLoader

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCache { [unowned self]error in
            if (error == nil) {
                self.store.insertCache()
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCacheCallCount = 0
    var insertionCacheCallCount = 0
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCache(completion: @escaping DeletionCompletion) {
        deleteCacheCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func insertCache() {
        insertionCacheCallCount += 1
    }
    
    func completeDeletionError(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSucessFully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesnotDeleteCacheUponCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.deleteCacheCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheCallCount, 1)
    }
    
    func test_save_doesNotRequestInsertionOnDeletionCacheError() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        let deletionError = anyError()
        store.completeDeletionError(deletionError)
        
        XCTAssertEqual(store.insertionCacheCallCount, 0)
    }
    
    func test_save_requestInsertionOnDeletionSucessfull() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSucessFully()
        
        XCTAssertEqual(store.insertionCacheCallCount, 1)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedStore, LocalFeedLoader){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackMemoryLeak(instance: store, file: file, line: line)
        trackMemoryLeak(instance: sut, file: file, line: line)
        return(store, sut)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageUrl: anyUrl())
    }
    
    private func anyUrl() -> URL {
        return URL(string: "http://any-given-url.com")!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any-error", code: 0, userInfo: nil)
    }
}
