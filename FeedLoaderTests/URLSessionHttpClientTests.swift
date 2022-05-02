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
        super.setUp()
        URLProtocolStub.startIngterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyUrl()
        makeSUT().get(from: url) { _ in }
        let exp = expectation(description: "fail request error")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: anyUrl()) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failOnRequestError() {
        let error = NSError(domain: "Any error", code: 1)
        URLProtocolStub.stub(error: error)
        
        let exp = expectation(description: "fail request error")
        makeSUT().get(from: anyUrl(), completion:  { result in
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
    
    private func anyUrl() -> URL {
        return URL(string: "http://any-given-url.com")!
    }
    
    private func makeSUT() -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        static func stub(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
            stubs = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startIngterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stubs else {
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
