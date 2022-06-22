//
//  ManagedFeedImage+CoreDataProperties.swift
//  FeedLoader
//
//  Created by AmritPandey on 22/06/22.
//
//

import Foundation
import CoreData


extension ManagedFeedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeedImage> {
        return NSFetchRequest<ManagedFeedImage>(entityName: "ManagedFeedImage")
    }

    @NSManaged public var id: UUID
    @NSManaged public var url: URL
    @NSManaged public var location: String?
    @NSManaged public var imageDescription: String?
    @NSManaged public var cache: ManagedCache?

    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, imageUrl: url)
    }
    
    static func managedFeedImages(localFeeds: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeeds.map { local in
            let managedFeedImage = ManagedFeedImage(context: context)
            managedFeedImage.id = local.id
            managedFeedImage.location = local.location
            managedFeedImage.imageDescription = local.description
            managedFeedImage.url = local.url
            return managedFeedImage
        })
    }
}

extension ManagedFeedImage : Identifiable {

}
