//
//  HttpClient.swift
//  FeedLoader
//
//  Created by AmritPandey on 18/04/22.
//

import Foundation

enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}


