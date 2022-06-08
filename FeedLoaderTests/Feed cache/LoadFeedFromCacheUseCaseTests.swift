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
        let exp = expectation(description: "Wait for completion")
        var receivedError: Error?
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got\(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrievalWithError(error: retrievalError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(retrievalError, receivedError as NSError?)
    }
    
    func test_load_deliverNoImageOnEmptyCache() {
        let (store, sut) = makeSUT()

        let exp = expectation(description: "Wait for completion")
        var receivedImages: [FeedImage]?
        sut.load { result in
            switch result {
            case let .success(images):
                receivedImages = images
            default:
                XCTFail("Expected success, got\(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetrievalWithEmptyCache()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedImages, [])
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

