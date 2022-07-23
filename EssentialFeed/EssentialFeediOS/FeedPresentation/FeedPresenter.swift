//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 21/07/22.
//

import EssentialFeed

final class FeedPresenter {
    private let view: FeedView
    private let loadingView: FeedLoadingView
    
    init(view: FeedView, loadingView: FeedLoadingView) {
        self.view = view
        self.loadingView = loadingView
    }
    
    func didStartLoading() {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feeds: [FeedImage]) {
        view.display(viewModel: FeedViewModel(feeds: feeds))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}

