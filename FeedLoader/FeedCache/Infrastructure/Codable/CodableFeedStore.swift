//
//  CodableFeedStore.swift
//  FeedLoader
//
//  Created by AmritPandey on 15/06/22.
//

import Foundation

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
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeUrl: URL
    
    init(_ storeURL: URL) {
        self.storeUrl = storeURL
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        let storeUrl = storeUrl
        queue.async {
            let decoder = JSONDecoder()
            guard let data = try? Data(contentsOf: storeUrl) else {
                return completion(.success(.empty))
            }
            
            do {
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(.found(feed: cache.localFeed, timestamp: cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteCache(completion: @escaping Completion) {
        let storeUrl = storeUrl
        queue.async(flags: .barrier) {
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
    }
    
    func insertCache(with items: [LocalFeedImage], timestamp: Date, completion: @escaping Completion) {
        let storeUrl = storeUrl
        queue.async(flags: .barrier) {
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
    
    
}
