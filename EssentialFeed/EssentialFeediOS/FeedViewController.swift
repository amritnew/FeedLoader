//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 12/07/22.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load () {
        refreshControl?.beginRefreshing()
        loader?.load{ [weak self] _ in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
        }
    }
}
