//
//  FeedStoreSpy.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 08/06/22.
//

import Foundation
@testable import FeedLoader

class FeedStoreSpy: FeedStore {
    typealias Completion = (Error?) -> Void
    typealias RetrievalCompletion = (FeedStore.RetrievalResult) -> Void
    
    enum RecievedMessage: Equatable {
        case retrieve
        case deleteCache
        case insertCache([LocalFeedImage], Date)
    }
    
    var recievedMessages = [RecievedMessage]()
    private var deletionCompletions = [Completion]()
    private var insertionCompletions = [Completion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func deleteCache(completion: @escaping Completion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deleteCache)
    }
    
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insertCache(items, timestamp))
    }
    
    func completeInsertionError(_ error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSucessFully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func completeDeletionError(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSucessFully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        recievedMessages.append(.retrieve)
    }
    
    func completeRetrievalWithError(error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completeRetrievalWith(imageCache: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(CacheFeed(feed: imageCache, timestamp: timestamp)))
    }
}
