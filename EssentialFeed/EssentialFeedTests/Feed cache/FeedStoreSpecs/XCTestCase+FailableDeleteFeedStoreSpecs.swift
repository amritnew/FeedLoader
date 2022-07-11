//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 20/06/22.
//

import XCTest
@testable import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = delete(sut: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        delete(sut: sut)
        
        expect(sut: sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
