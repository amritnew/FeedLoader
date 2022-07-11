//
//  URLSessionHttpClient.swift
//  FeedLoader
//
//  Created by AmritPandey on 06/05/22.
//

import Foundation


class URLSessionHttpClient: HTTPClient {
    private let session: URLSession
    
    struct InvalidRepresentation: Error {}
    
    init(urlSession: URLSession = .shared) {
        self.session = urlSession
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let err = error {
                    throw err
                }
                else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                }
                else {
                    throw InvalidRepresentation()
                }
            })
            
        }.resume()
    }
}
