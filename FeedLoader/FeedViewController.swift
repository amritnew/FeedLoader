//
//  ViewController.swift
//  FeedLoader
//
//  Created by AmritPandey on 13/04/22.
//

import UIKit

protocol FeedLoader {
    func loadFeed(completion: @escaping (([String]) -> Void))
}

class FeedViewController: UIViewController {
    var loader: FeedLoader!
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.loadFeed { loadedItems in
            //update UI
        }
    }

}


