//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 20/07/22.
//

import EssentialFeed

final class FeedImageViewModel<Image> {
    
    typealias Observer<T> = ((T) -> Void)
    
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage
    private let imageTransformer: ((Data) -> Image?)
    
    init(model: FeedImage,  imageLoader: FeedImageDataLoader, imageTranformer: @escaping ((Data) -> Image?)) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTranformer
    }
    
    var hasLocation: Bool {
        return model.location != nil
    }
    
    var location: String? {
        return model.location
    }
    
    var description: String? {
        return model.description
    }
    
    var onImageLoad: Observer<Image>?
    var OnImageLoadingStateChange: Observer<Bool>?
    var OnShouldRetryStateChange: Observer<Bool>?
    
    func loadImage() {
        OnImageLoadingStateChange?(true)
        OnShouldRetryStateChange?(false)
        task = imageLoader.loadImageData(from: model.url, completion: { [weak self] result in
            self?.handle(result)
        })
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            OnShouldRetryStateChange?(true)
        }
        OnImageLoadingStateChange?(false)
    }
        
    func preload() {
        task = imageLoader.loadImageData(from: model.url, completion: { _ in })
    }
    
    func cancelImageLoad() {
        task?.cancel()
    }
}
