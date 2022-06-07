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
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCache { [unowned self]error in
            if (error == nil) {
                self.store.insertCache(with: items, timestamp: self.currentDate(), completion: completion)
            }
            else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias Completion = (Error?) -> Void
    
    enum RecievedMessage: Equatable {
        case deleteCache
        case insertCache([FeedItem], Date)
    }
    
    var recievedMessages = [RecievedMessage]()
    private var deletionCompletions = [Completion]()
    private var insertionCompletions = [Completion]()
    
    func deleteCache(completion: @escaping Completion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deleteCache)
    }
    
    func insertCache(with items: [FeedItem], timestamp: Date, completion: @escaping Completion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insertCache(items, timestamp))
    }
    
    func completeInsertionError(_ error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeDeletionError(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSucessFully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesnotHaveAnyMessageUponCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) {_ in }
        
        XCTAssertEqual(store.recievedMessages, [.deleteCache])
    }
    
    func test_save_doesNotRequestInsertionOnDeletionCacheError() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) {_ in }
        let deletionError = anyError()
        store.completeDeletionError(deletionError)
        
        XCTAssertEqual(store.recievedMessages, [.deleteCache])
    }
    
    func test_save_requestInsertionWithTimestampOnDeletionSucessfull() {
        let timestamp = Date()
        let (store, sut) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) {_ in }
        store.completeDeletionSucessFully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCache, .insertCache(items, timestamp)])
    }
    
    func test_save_failsOnDeletionCacheError() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        let deletionError = anyError()
        store.completeDeletionError(deletionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    func test_save_failsOnInsertionCacheError() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        let insertionError = anyError()
        store.completeDeletionSucessFully()
        store.completeInsertionError(insertionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, insertionError)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (FeedStore, LocalFeedLoader){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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
