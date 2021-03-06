//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by AmritPandey on 08/07/22.
//

import XCTest
import UIKit
@testable import FeedLoader

final class FeedViewController: UIViewController {
    private var loader: FeedLoader?
    
//    convenience init(loader: FeedLoader) {
//        self.init()
//        self.loader = loader
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loader?.load(completion: { _ in })
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        //_ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
//        let sut = FeedViewController(loader: loader)
//
//        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    //MARK: Helpers
    class LoaderSpy {
        
        private(set) var loadCallCount = 0
        
//        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
//            loadCallCount += 1
//        }
    }
    
}
