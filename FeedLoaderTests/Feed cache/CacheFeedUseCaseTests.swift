//
//  CacheFeedUseCaseTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 07/06/22.
//

import Foundation
import XCTest
@testable import FeedLoader

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
        sut.save([uniqueItem()]) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                receivedError = error
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
}
