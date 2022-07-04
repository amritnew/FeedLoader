//
//  HttpClient.swift
//  FeedLoader
//
//  Created by AmritPandey on 18/04/22.
//

import Foundation

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    /// The Completion Handler can be invoked in any thread
    /// Client are responsible to dispatchto appropriate thread. if needed
    func get(from url: URL, completion: @escaping (Result) -> Void)
}


