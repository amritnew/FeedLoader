//
//  URLSessionHttpClientTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 29/04/22.
//

import XCTest
@testable import FeedLoader


class URLSessionHttpClient {
    private let session: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.session = urlSession
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let err = error {
                completion(.failure(err))
            }
        }.resume()
    }
}


class URLSessionHttpClientTests: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startIngterceptingRequests()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_failOnRequestError() {
        let url = URL(string: "https://any-url.com")!
        
        let error = NSError(domain: "Any error", code: 1)
        URLProtocolStub.stub(for: url, error: error)
        let sut = URLSessionHttpClient()
        
        let exp = expectation(description: "fail request error")
        sut.get(from: url, completion:  { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail()
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    //MARK: Helpers
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        static func stub(for url: URL, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startIngterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}
