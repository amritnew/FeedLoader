//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 20/07/22.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = ((T) -> Void)
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    @objc func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load{ [weak self] result in
            guard let self = self else { return }
            if let feeds = try? result.get() {
                self.onFeedLoad?(feeds)
            }
            self.onLoadingStateChange?(false)
        }
    }
}
