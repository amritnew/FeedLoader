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
    
    func completeInsertionSucessFully(at index: Int = 0) {
        insertionCompletions[index](nil)
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
        let item = uniqueImageFeed()
        sut.save(item.models) {_ in }
        
        XCTAssertEqual(store.recievedMessages, [.deleteCache])
    }
    
    func test_save_doesNotRequestInsertionOnDeletionCacheError() {
        let (store, sut) = makeSUT()
        let item = uniqueImageFeed()
        sut.save(item.models) {_ in }
        let deletionError = anyError()
        store.completeDeletionError(deletionError)
        
        XCTAssertEqual(store.recievedMessages, [.deleteCache])
    }
    
    func test_save_requestInsertionWithTimestampOnDeletionSucessfull() {
        let timestamp = Date()
        let (store, sut) = makeSUT(currentDate: { timestamp })
        let item = uniqueImageFeed()
        sut.save(item.models) {_ in }
        store.completeDeletionSucessFully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCache, .insertCache(item.localModels, timestamp)])
    }
    
    func test_save_failsOnDeletionCacheError() {
        let (store, sut) = makeSUT()
        
        let deletionError = anyError()
        expect(sut: sut, toCompleteWith: deletionError) {
            store.completeDeletionError(deletionError)
        }
    }
    
    func test_save_failsOnInsertionCacheError() {
        let (store, sut) = makeSUT()
        
        let insertionError = anyError()
        expect(sut: sut, toCompleteWith: insertionError) {
            store.completeDeletionSucessFully()
            store.completeInsertionError(insertionError)
        }
    }
    
    func test_save_sucessOnSucessfullCacheInsertion() {
        let (store, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWith: nil) {
            store.completeDeletionSucessFully()
            store.completeInsertionSucessFully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store) { Date() }
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItem()]) { receivedResults.append($0) }
        
        sut = nil
        let deletionError = anyError()
        store.completeDeletionError(deletionError)
                
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store) { Date() }
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItem()]) { receivedResults.append($0) }
        
        let insertionError = anyError()
        store.completeDeletionSucessFully()
        sut = nil
        store.completeInsertionError(insertionError)
                
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (FeedStoreSpy, LocalFeedLoader){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(instance: store, file: file, line: line)
        trackMemoryLeak(instance: sut, file: file, line: line)
        return(store, sut)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueItem() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyUrl())
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], localModels: [LocalFeedImage]) {
        let items = [uniqueItem(), uniqueItem()]
        let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.url) }
        return(items, localItems)
    }
    
    private func anyUrl() -> URL {
        return URL(string: "http://any-given-url.com")!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any-error", code: 0, userInfo: nil)
    }
    
    
}
