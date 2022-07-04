//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 20/06/22.
//

import XCTest
@testable import FeedLoader


extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImageFeed().localModels, Date()), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed().localModels, Date()), to: sut)
        
        expect(sut: sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}

