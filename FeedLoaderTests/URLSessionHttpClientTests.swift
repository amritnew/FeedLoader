//
//  URLSessionHttpClientTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 29/04/22.
//

import XCTest

class URLSessionHttpClient {
    private let session: URLSession
    
    init(urlSession: URLSession) {
        self.session = urlSession
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in
            
        }
    }
}


class URLSessionHttpClientTests: XCTestCase {

    func test_getFromURL_createDatataskFromURL() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHttpClient(urlSession: session)
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedUrls, [url])
    }

    
    //MARK: Helpers
    private class URLSessionSpy: URLSession {
        var receivedUrls = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {  }
}
