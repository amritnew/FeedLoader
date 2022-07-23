//
//  FeedLoadingViewModel.swift
//  EssentialFeediOS
//
//  Created by AmritPandey on 21/07/22.
//

import Foundation

struct FeedLoadingViewModel {
    let isLoading: Bool
}
protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}
