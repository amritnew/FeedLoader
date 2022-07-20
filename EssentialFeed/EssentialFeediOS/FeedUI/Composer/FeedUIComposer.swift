//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 19/07/22.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwradingTo: feedViewController, imageLoader: imageLoader)
        
        return feedViewController
    }
    
    private static func adaptFeedToCellControllers(forwradingTo feedViewController:FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map({ feed in
                let imageViewModel = FeedImageViewModel(model: feed, imageLoader: imageLoader, imageTranformer: UIImage.init)
                return FeedImageCellController(viewModel: imageViewModel)
            })
        }
    }
}
