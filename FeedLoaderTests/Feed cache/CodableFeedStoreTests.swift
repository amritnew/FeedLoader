//
//  CodableFeedStoreTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 13/06/22.
//

import XCTest
@testable import FeedLoader

class CodableFeedStore: FeedStore {
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    func deleteCache(completion: @escaping Completion) {
        
    }
    
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        
    }
    
    
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, instead got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retieving twice from  empty cache to deliver same result empty result, instead got \(firstResult) and \(secondResult)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
