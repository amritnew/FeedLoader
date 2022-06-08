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
    
    enum RecievedMessage: Equatable {
        case deleteCache
        case insertCache([LocalFeedImage], Date)
    }
    
    var recievedMessages = [RecievedMessage]()
    private var deletionCompletions = [Completion]()
    private var insertionCompletions = [Completion]()
    
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
}
