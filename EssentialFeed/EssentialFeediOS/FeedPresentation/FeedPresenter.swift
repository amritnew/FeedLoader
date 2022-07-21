//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 21/07/22.
//

import EssentialFeed


struct FeedLoadingViewModel {
    let isLoading: Bool
}
protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feeds: [FeedImage]
}
protocol FeedView {
    func display(viewModel: FeedViewModel)
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
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
        feedLoader.load{ [weak self] result in
            guard let self = self else { return }
            if let feeds = try? result.get() {
                self.view?.display(viewModel: FeedViewModel(feeds: feeds))
            }
            self.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
        }
    }
}

