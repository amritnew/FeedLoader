//
//  CodableFeedStoreTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 13/06/22.
//

import XCTest
@testable import FeedLoader

class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map{ $0.local }
        }
    }
    
    struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        
        init(_ imageFeed: LocalFeedImage) {
            id = imageFeed.id
            description = imageFeed.description
            location = imageFeed.location
            url = imageFeed.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, imageUrl: url)
        }
    }
    
    private let storeUrl: URL
    
    init(_ storeURL: URL) {
        self.storeUrl = storeURL
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        
        do {
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteCache(completion: @escaping Completion) {
        guard FileManager.default.fileExists(atPath: storeUrl.path) else {
            return completion(nil)
        }
        do {
            try FileManager.default.removeItem(at: storeUrl)
            completion(nil)
        }
        catch {
            completion(error)
        }
    }
    
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(feed: items.map(CodableFeedImage.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeUrl)
            completion(nil)
        }
        catch {
            completion(error)
        }
        
    }
    
    
}

class CodableFeedStoreTests: XCTestCase {
    
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
     
    //MARK: Helpers
    
    private func makeSUT(storeUrl: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeUrl ?? testSpecificStoreURL())
        trackMemoryLeak(instance: sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insertCache(with: cache.feed, timestamp: cache.timestamp) { error in
            insertionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func delete(sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCache { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func expect(sut: FeedStore, toRetrieveTwice expectedResult: RetrievalCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut: sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(sut: FeedStore, toRetrieve expectedResult: RetrievalCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retieval")
        sut.retrieve { retrivedResult in
            switch (retrivedResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(retrived), .found(expected)):
                XCTAssertEqual(retrived.feed, expected.feed)
                XCTAssertEqual(retrived.timestamp, expected.timestamp)
                
            default:
                XCTFail("Expected \(expectedResult) instead got \(retrivedResult)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
