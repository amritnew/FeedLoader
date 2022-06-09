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
}
