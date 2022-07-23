//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 12/07/22.
//

import UIKit

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    var delegate: FeedRefreshViewControllerDelegate?
    @IBOutlet var refreshController: UIRefreshControl?
    
    public override func viewDidLoad() {
        refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
        
    }
    
    private func cancelCellController(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

//MARK: - Refresh Controller
extension FeedViewController: FeedLoadingView {
        
    @IBAction func refresh () {
        delegate?.didRequestFeedRefresh()
    }

    
    func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshController?.beginRefreshing()
        }
        else {
            refreshController?.endRefreshing()
        }
    }
}


