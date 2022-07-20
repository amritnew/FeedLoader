//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 19/07/22.
//

import UIKit

final class FeedImageCellController {
    
    private var task: FeedImageDataLoaderTask?
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        binded(cell)
        viewModel.loadImage()
        return cell
    }
    
    func binded(_ cell: FeedImageCell) {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.OnImageLoadingStateChange = { [weak cell] loading in
            if loading {
                cell?.feedImageContainer.startShimmer()
            }
            else {
                cell?.feedImageContainer.stopShimmer()
            }
        }
        
        viewModel.OnShouldRetryStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }

        cell.onRetry = viewModel.loadImage
        
    }
    
    func preload() {
        viewModel.preload()
    }
    
    func cancelLoad() {
        viewModel.cancelImageLoad()
    }
}
