//
//  CoreDataFeedStore.swift
//  FeedLoader
//
//  Created by AmritPandey on 21/06/22.
//

import Foundation
import CoreData

final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(storeUrl: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeUrl, in: bundle)
        context = container.newBackgroundContext()
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.fetchRequest(context: context).map { cache in
                    return CacheFeed(feed: cache.localFeeds, timestamp: cache.timestamp)
                }
            })
        }
    }
    
    func deleteCache(completion: @escaping Completion) {
        perform { context in
            completion(Result{
                try ManagedCache.fetchRequest(context: context).map { context.delete($0) }
            })
        }
    }
    
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        perform { context in
            completion(Result {
                let cache = try ManagedCache.newUniqueInstance(in: context)
                cache.timestamp = timestamp
                cache.feed = ManagedFeedImage.managedFeedImages(localFeeds: items, in: context)
                
                try context.save()
            })
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
    
}
