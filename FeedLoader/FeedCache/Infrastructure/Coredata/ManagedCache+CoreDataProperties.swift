//
//  ManagedCache+CoreDataProperties.swift
//  FeedLoader
//
//  Created by AmritPandey on 22/06/22.
//
//

import Foundation
import CoreData


extension ManagedCache {

    @nonobjc public class func fetchRequest(context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try ManagedCache.fetchRequest(context: context).map{context.delete($0)}
        return ManagedCache(context: context)
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var feed: NSOrderedSet
    
    var localFeeds: [LocalFeedImage] {
        return feed.compactMap{ ($0 as? ManagedFeedImage)?.local }
    }

}

// MARK: Generated accessors for feed
extension ManagedCache {

    @objc(insertObject:inFeedAtIndex:)
    @NSManaged public func insertIntoFeed(_ value: ManagedFeedImage, at idx: Int)

    @objc(removeObjectFromFeedAtIndex:)
    @NSManaged public func removeFromFeed(at idx: Int)

    @objc(insertFeed:atIndexes:)
    @NSManaged public func insertIntoFeed(_ values: [ManagedFeedImage], at indexes: NSIndexSet)

    @objc(removeFeedAtIndexes:)
    @NSManaged public func removeFromFeed(at indexes: NSIndexSet)

    @objc(replaceObjectInFeedAtIndex:withObject:)
    @NSManaged public func replaceFeed(at idx: Int, with value: ManagedFeedImage)

    @objc(replaceFeedAtIndexes:withFeed:)
    @NSManaged public func replaceFeed(at indexes: NSIndexSet, with values: [ManagedFeedImage])

    @objc(addFeedObject:)
    @NSManaged public func addToFeed(_ value: ManagedFeedImage)

    @objc(removeFeedObject:)
    @NSManaged public func removeFromFeed(_ value: ManagedFeedImage)

    @objc(addFeed:)
    @NSManaged public func addToFeed(_ values: NSOrderedSet)

    @objc(removeFeed:)
    @NSManaged public func removeFromFeed(_ values: NSOrderedSet)
    
}

extension ManagedCache : Identifiable {

}
