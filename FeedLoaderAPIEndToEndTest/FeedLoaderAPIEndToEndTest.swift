//
//  FeedLoaderAPIEndToEndTest.swift
//  FeedLoaderAPIEndToEndTest
//
//  Created by AmritPandey on 16/05/22.
//

import XCTest
@testable import FeedLoader

class FeedLoaderAPIEndToEndTests: XCTestCase {

    func test_endToEndTestGetServerResult_matchesFixedTestAccounctData() {
        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 8, "Expected 8 items from test account")
            
        case let .failure(error)? :
            XCTFail("Expecting items from api but got \(error) instead")
            
        default:
            XCTFail("Expecting items from api but got failure instead")
        }
    }
    
    //MARK: - Helpers
    
    func getFeedResult(file: StaticString = #file, line: UInt = #line) -> RemoteFeedLoader.Result? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHttpClient()
        let loader = RemoteFeedLoader(url: url, client: client)
        trackMemoryLeak(instance: client, file: file, line: line)
        trackMemoryLeak(instance: loader, file: file, line: line)
        let exp = expectation(description: "Wait for downlaoding data")
        var receivedResult: RemoteFeedLoader.Result?
        loader.loadFeed { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }

}