//
//  XCTestCase+MemoryLeakTracking.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 02/05/22.
//

import XCTest

extension XCTestCase {
    
    func trackMemoryLeak(instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance of sut have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
