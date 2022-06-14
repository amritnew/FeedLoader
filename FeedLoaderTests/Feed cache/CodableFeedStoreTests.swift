//
//  CodableFeedStoreTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 13/06/22.
//

import XCTest
@testable import FeedLoader

class CodableFeedStore {
    
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
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(cache.localFeed, cache.timestamp))
    }
    
    func deleteCache(completion: @escaping FeedStore.Completion) {
        
    }
    
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.Completion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: items.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeUrl)
        completion(nil)
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
        let sut = makeSUT()
        
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
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValue() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localModels
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for cache retieval")
        sut.insertCache(with: feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedFeed, retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    break
                default:
                    XCTFail("Expected found result with \(feed) and \(timestamp), got \(retrieveResult) instead ")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localModels
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for cache retieval")
        sut.insertCache(with: feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstFoundFeed, firstFoundTimestamp), .found(secondFoundFeed, secondFoundTimestamp)):
                        XCTAssertEqual(firstFoundFeed, feed)
                        XCTAssertEqual(firstFoundTimestamp, timestamp)
                        
                        XCTAssertEqual(secondFoundFeed, feed)
                        XCTAssertEqual(secondFoundTimestamp, timestamp)
                        break
                    default:
                        XCTFail("Expected retieving twice from  empty cache to deliver same result empty result, instead got \(firstResult) and \(secondResult)")
                    }
                    exp.fulfill()
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
     
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore{
        let codable = CodableFeedStore(testSpecificStoreURL())
        trackMemoryLeak(instance: codable, file: file, line: line)
        return codable
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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
