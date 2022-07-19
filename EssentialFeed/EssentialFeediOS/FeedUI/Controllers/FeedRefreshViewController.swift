//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 19/07/22.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let feedLoader: FeedLoader
    var onRefresh: (([FeedImage]) -> Void)?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    @objc func refresh () {
        view.beginRefreshing()
        feedLoader.load{ [weak self] result in
            guard let self = self else { return }
            if let feeds = try? result.get() {
                self.onRefresh?(feeds)
            }
            self.view.endRefreshing()
        }
    }
}
