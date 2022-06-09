//
//  LoadFeedFromCacheUseCaseTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 08/06/22.
//

import Foundation
import XCTest
@testable import FeedLoader

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesnotHaveAnyMessageUponCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
     
    func test_load_cacheRetrieval() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (store, sut) = makeSUT()
        let retrievalError = anyError()
        
        expect(sut, toCompleteWithResult: .failure(retrievalError)) {
            store.completeRetrievalWithError(error: retrievalError)
        }

    }
    
    func test_load_deliverNoImageOnEmptyCache() {
        let (store, sut) = makeSUT()

        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliverImageCacheOnLessthanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let lessThanSevenDaysOld = currentDate.adding(days: -7).adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        expect(sut, toCompleteWithResult: .success(feed.models)) {
            store.completeRetrievalWith(imageCache: feed.localModels, timestamp: lessThanSevenDaysOld )
        }
    }
    
    func test_load_deliverEmptyImageCacheOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let lessThanSevenDaysOld = currentDate.adding(days: -7)
        let (store, sut) = makeSUT { currentDate }
        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrievalWith(imageCache: feed.localModels, timestamp: lessThanSevenDaysOld )
        }
    }
    
    func test_load_deliverEmptyImageCacheOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let lessThanSevenDaysOld = currentDate.adding(days: -7).adding(seconds: -1)
        let (store, sut) = makeSUT { currentDate }
        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrievalWith(imageCache: feed.localModels, timestamp: lessThanSevenDaysOld )
        }
    }
    
    func test_load_deleteCacheOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithError(error: anyError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCache])
    }
    
    func test_load_doesnotDeleteCacheOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_doesnotDeleteCacheOnlessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let lessThanSevenDaysOld = currentDate.adding(days: -7).adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load {_ in }
        store.completeRetrievalWith(imageCache: feed.localModels, timestamp: lessThanSevenDaysOld)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_deleteCacheOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let sevenDaysOld = currentDate.adding(days: -7)
        let (store, sut) = makeSUT { currentDate }
        
        sut.load {_ in }
        store.completeRetrievalWith(imageCache: feed.localModels, timestamp: sevenDaysOld)
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCache])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (FeedStoreSpy, LocalFeedLoader){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(instance: store, file: file, line: line)
        trackMemoryLeak(instance: sut, file: file, line: line)
        return(store, sut)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithResult expectedResult: LocalFeedLoader.LoadResult<Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let expectation = expectation(description: "Wair for load completion")
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedImages), .success(expectedImages)):
                XCTAssertEqual(recievedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got instead \(recievedResult)", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
    }

    private func anyError() -> NSError {
        return NSError(domain: "any-error", code: 0, userInfo: nil)
    }
    
    private func uniqueItem() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyUrl())
    }
    
    private func anyUrl() -> URL {
        return URL(string: "http://any-given-url.com")!
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], localModels: [LocalFeedImage]) {
        let items = [uniqueItem(), uniqueItem()]
        let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.url) }
        return(items, localItems)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
