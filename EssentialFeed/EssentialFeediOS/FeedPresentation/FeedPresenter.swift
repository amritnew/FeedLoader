//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 21/07/22.
//

import EssentialFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = ((T) -> Void)
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var view: FeedView?
    var loadingView: FeedLoadingView?
    
    @objc func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load{ [weak self] result in
            guard let self = self else { return }
            if let feeds = try? result.get() {
                self.view?.display(feed: feeds)
            }
            self.loadingView?.display(isLoading: false)
        }
    }
}

