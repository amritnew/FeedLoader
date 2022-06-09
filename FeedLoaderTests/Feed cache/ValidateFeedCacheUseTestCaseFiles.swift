//
//  ValidateFeedCacheUseTestCaseFiles.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 09/06/22.
//

import XCTest
@testable import FeedLoader

class ValidateFeedCacheUseTestCaseFiles: XCTestCase {

    func test_init_doesnotHaveAnyMessageUponCreation() {
        let (store, _) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_validate_deleteCacheOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.validate()
        store.completeRetrievalWithError(error: anyError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve, .deleteCache])
    }
    
    func test_validate_doesnotDeleteCacheOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.validate()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validate_doesnotDeletelessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let currentDate = Date()
        let lessThanSevenDaysOld = currentDate.adding(days: -7).adding(seconds: 1)
        let (store, sut) = makeSUT { currentDate }
        
        sut.validate()
        store.completeRetrievalWith(imageCache: feed.localModels, timestamp: lessThanSevenDaysOld)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }

    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (FeedStoreSpy, LocalFeedLoader){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(instance: store, file: file, line: line)
        trackMemoryLeak(instance: sut, file: file, line: line)
        return(store, sut)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any-error", code: 0, userInfo: nil)
    }
    
    private func anyUrl() -> URL {
        return URL(string: "http://any-given-url.com")!
    }
    
    private func uniqueItem() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyUrl())
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
