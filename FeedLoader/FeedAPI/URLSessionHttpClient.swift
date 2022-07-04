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
            if let err = error {
                completion(.failure(err))
            }
            else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response) ))
            }
            else {
                completion(.failure(InvalidRepresentation()))
            }
        }.resume()
    }
}
