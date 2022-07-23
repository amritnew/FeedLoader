//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 21/07/22.
//

import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let feedImage: View?
    private let imageTransformer: ((Data) -> Image?)
    
    init(feedImage:View, imageTranformer: @escaping ((Data) -> Image?)) {
        self.feedImage = feedImage
        self.imageTransformer = imageTranformer
    }
    
    func didStartLoadingImage(model: FeedImage) {
        feedImage?.display(FeedImageViewModel(isLoading: true,
                                              shoulretry: false,
                                              description: model.description,
                                              location: model.location,
                                              image: nil))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        feedImage?.display(FeedImageViewModel(isLoading: false,
                                              shoulretry: false,
                                              description: model.description,
                                              location: model.location,
                                              image: image))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        feedImage?.display(FeedImageViewModel(isLoading: false,
                                              shoulretry: true,
                                              description: model.description,
                                              location: model.location,
                                              image: nil))
    }
        
}
