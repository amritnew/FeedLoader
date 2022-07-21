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
    
    var view: FeedView?
    var loadingView: FeedLoadingView?
    
    func didStartLoading() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feeds: [FeedImage]) {
        view?.display(viewModel: FeedViewModel(feeds: feeds))
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}

