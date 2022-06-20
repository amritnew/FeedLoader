//
//  CodableFeedStoreTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 13/06/22.
//

import XCTest
@testable import FeedLoader

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    
    override func setUp() {
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        undoStoreState()
    }
    
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieve: .empty)
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localModels
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut: sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localModels
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut: sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeUrl: storeUrl)
        
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieve: .failure(anyError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let insertionError = insert((uniqueImageFeed().localModels, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().localModels, Date()), to: sut)

        let insertionError = insert((uniqueImageFeed().localModels, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }


    func test_retrieve_hasNoSideEffectOnRetrievalError() {
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeUrl: storeUrl)
        
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieveTwice: .failure(anyError()))
    }
    
    func test_insert_overridesPreviousInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localModels
        
        let insertionError = insert((feed, Date()), to: sut)
        XCTAssertNil(insertionError, "Epected to insert succesfully")
        
        let latestFeed = uniqueImageFeed().localModels
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Epected to insert succesfully")
        
        expect(sut: sut, toRetrieveTwice: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let storeUrl = URL(string: "invalidUrl://any-store-url")!
        let sut = makeSUT(storeUrl: storeUrl)
        
        let insertionError = insert((uniqueImageFeed().localModels, Date()), to: sut)
        XCTAssertNotNil(insertionError, "Epected insertion error")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let storeUrl = URL(string: "invalidUrl://any-store-url")!
        let sut = makeSUT(storeUrl: storeUrl)
        
        insert((uniqueImageFeed().localModels, Date()), to: sut)
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = delete(sut: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        delete(sut: sut)
        
        expect(sut:sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = delete(sut: sut)
        XCTAssertNil(deletionError, "Epected empty cache deletion to succeed")
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localModels
        
        let insertionError = insert((feed, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to insert succesfully")
        
        let deletionError = delete(sut: sut)
        XCTAssertNil(deletionError, "Expected non empty cache deletion to succeed")
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_deliverErrorOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeUrl: noDeletePermissionURL)

        let deletionError = delete(sut: sut)
        XCTAssertNotNil(deletionError, "Expected deletion error")
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoEffectOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeUrl: noDeletePermissionURL)

        delete(sut: sut)
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_storeSodeEffects_runSerially() {
        let sut = makeSUT()
        
        var completedOperations = [XCTestExpectation]()
        let op1 = expectation(description: "Wait for cache insertion")
        sut.insertCache(with: uniqueImageFeed().localModels, timestamp: Date()) { _ in
            completedOperations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Wait for cache deletion")
        sut.deleteCache { _ in
            completedOperations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Wait for cache retrieval")
        sut.retrieve { _ in
            completedOperations.append(op3)
            op3.fulfill()
        }
        
        wait(for: [op1, op2, op3], timeout: 1.0)
        
        XCTAssertEqual(completedOperations, [op1, op2, op3], "Expected side effects to finish serially but operation finifshed in wrong order")
    }
     
    //MARK: Helpers
    
    private func makeSUT(storeUrl: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeUrl ?? testSpecificStoreURL())
        trackMemoryLeak(instance: sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func noDeletePermissionURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
    
    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreState() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
