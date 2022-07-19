//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 19/07/22.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(forwradingTo: feedViewController, imageLoader: imageLoader)
        
        return feedViewController
    }
    
    private static func adaptFeedToCellControllers(forwradingTo feedViewController:FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map({ feed in
                return FeedImageCellController(model: feed, imageLoader: imageLoader)
            })
        }
    }
}
