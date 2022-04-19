//
//  HttpClient.swift
//  FeedLoader
//
//  Created by AmritPandey on 18/04/22.
//

import Foundation


protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}


