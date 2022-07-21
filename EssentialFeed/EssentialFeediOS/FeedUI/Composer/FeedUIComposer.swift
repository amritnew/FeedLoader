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
        let feedPresneter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: feedPresneter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedPresneter.loadingView = refreshController
        feedPresneter.view = FeedViewAdapter(feedViewController: feedViewController, imageLoader: imageLoader)
        
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

private final class FeedViewAdapter: FeedView {
    private weak var feedViewController:FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(feedViewController:FeedViewController, imageLoader: FeedImageDataLoader) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
    
    func display(feed: [FeedImage]) {
        feedViewController?.tableModel = feed.map({ feed in
            let imageViewModel = FeedImageViewModel(model: feed, imageLoader: imageLoader, imageTranformer: UIImage.init)
            return FeedImageCellController(viewModel: imageViewModel)
        })
    }
    
}
