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
        let context = self.context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    completion(.found(
                        feed: cache.feed
                            .compactMap({ $0 as? ManagedFeedImage })
                            .map({ LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, imageUrl: $0.url) })
                        ,timestamp: cache.timestamp))
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
        
    }
    
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        let context = self.context
        context.perform {
            do {
                let cache = ManagedCache(context: context)
                cache.timestamp = timestamp
                cache.feed = NSOrderedSet(array: items.map { item in
                    let managedFeedImage = ManagedFeedImage(context: context)
                    managedFeedImage.id = item.id
                    managedFeedImage.location = item.location
                    managedFeedImage.imageDescription = item.description
                    managedFeedImage.url = item.url
                    return managedFeedImage
                })
                
                try context.save()
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
}

extension NSPersistentContainer {
    
    enum LoadingError: Error {
        case modelNotFound
        case failedToLoadPersistenceStore(Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistenceStore($0) }
        return container
    }
}

extension NSManagedObjectModel {
    
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap{ NSManagedObjectModel(contentsOf: $0) }
    }
}


