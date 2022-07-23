//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 21/07/22.
//

import EssentialFeed

struct FeedViewModel {
    let feeds: [FeedImage]
}
protocol FeedView {
    func display(viewModel: FeedViewModel)
}
