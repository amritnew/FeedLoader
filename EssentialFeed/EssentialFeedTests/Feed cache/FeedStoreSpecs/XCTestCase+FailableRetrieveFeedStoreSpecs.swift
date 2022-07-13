//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 20/06/22.
//

import Foundation

import XCTest
@testable import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut:sut, toRetrieve: .failure(anyError()), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetrieveTwice: .failure(anyError()), file: file, line: line)
    }
}
