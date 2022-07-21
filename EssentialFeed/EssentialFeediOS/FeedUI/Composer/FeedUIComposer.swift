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
        let feedPreseneter = FeedPresenter()
        let presentationAdapter = FeedPresenterAdapter(feedLoader: feedLoader, presenter: feedPreseneter)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedPreseneter.loadingView = WeaKRefVirtualProxy(refreshController)
        feedPreseneter.view = FeedViewAdapter(feedViewController: feedViewController, imageLoader: imageLoader)
        
        return feedViewController
    }
}

private final class WeaKRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeaKRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var feedViewController:FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(feedViewController:FeedViewController, imageLoader: FeedImageDataLoader) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
    
    func display(viewModel: FeedViewModel) {
        feedViewController?.tableModel = viewModel.feeds.map({ feed in
            let imageViewModel = FeedImageViewModel(model: feed, imageLoader: imageLoader, imageTranformer: UIImage.init)
            return FeedImageCellController(viewModel: imageViewModel)
        })
    }
    
}

private final class FeedPresenterAdapter: FeedRefreshViewControllerDelegate  {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoading()
        feedLoader.load{ [weak self] result in
            switch result {
            case let .success(feeds):
                self?.presenter.didFinishLoadingFeed(with: feeds)
            case let .failure(error):
                self?.presenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}
