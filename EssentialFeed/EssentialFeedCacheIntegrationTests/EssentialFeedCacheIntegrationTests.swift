//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by AmritPandey on 11/07/22.
//

import XCTest
@testable import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        undoStoreState()
    }
    
    func test_load_deliverNoItemOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toLoad: [])
    }
    
    func test_load_deliverItemsSavedOnSeperateInstances() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(feed: feed, with: sutToPerformSave)
        
        expect(sut: sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overrideItemsSavedOnSeperateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(feed: firstFeed, with: sutToPerformFirstSave)
        
        save(feed: latestFeed, with: sutToPerformLastSave)
        
        expect(sut: sutToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeUrl = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeUrl: storeUrl, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackMemoryLeak(instance: store, file: file, line: line)
        trackMemoryLeak(instance: sut, file: file, line: line)
        return sut
    }
    
    private func expect(sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load expectation")
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, expectedFeed, file:file, line: line)
            case let .failure(error):
                XCTFail("Expected sucessfull feed result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(feed) { saveResult in
            switch saveResult {
            case .success:
                break
            case let .failure(error):
                XCTAssertNil(error, "Expected to save feed succesfull", file: file, line: line)
            }
            
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        return cacheDirectory().appendingPathComponent("\(type(of: self)).store)")
    }
    
    private func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
