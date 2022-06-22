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
            do {
                if let cache = try ManagedCache.fetchRequest(context: context) {
                    completion(.found(
                        feed: cache.localFeeds ,timestamp: cache.timestamp))
                }
                else {
                    completion(.empty)
                }
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteCache(completion: @escaping Completion) {
        perform { context in
            do {
                try ManagedCache.fetchRequest(context: context).map { context.delete($0) }
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        perform { context in
            do {
                let cache = try ManagedCache.newUniqueInstance(in: context)
                cache.timestamp = timestamp
                cache.feed = ManagedFeedImage.managedFeedImages(localFeeds: items, in: context)
                
                try context.save()
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {
            action(context)
        }
    }
    
}
