//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 20/07/22.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange:((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    @objc func loadFeed() {
        isLoading = true
        feedLoader.load{ [weak self] result in
            guard let self = self else { return }
            if let feeds = try? result.get() {
                self.onFeedLoad?(feeds)
            }
            self.isLoading = false
        }
    }
}
