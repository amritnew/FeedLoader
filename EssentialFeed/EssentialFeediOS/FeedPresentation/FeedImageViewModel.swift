//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 20/07/22.
//

import EssentialFeed

struct FeedImageViewModel<Image> {
    let isLoading: Bool
    let shoulretry: Bool
    let description: String?
    let location: String?
    let image: Image?
    
    var hasLocation: Bool {
        return location != nil
    }
}
