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
    
    struct InvalidRepresentation: Error {}
    
    init(urlSession: URLSession = .shared) {
        self.session = urlSession
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let err = error {
                completion(.failure(err))
            }
            else {
                completion(.failure(InvalidRepresentation()))
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
        let requestError = NSError(domain: "Any error", code: 1)
        if let recievedError = resultErrorFor(error: requestError) as NSError? {
            XCTAssertEqual(recievedError.domain, requestError.domain)
            XCTAssertEqual(recievedError.code, requestError.code)
        }
    }

    func test_getFromURL_failOnAllNilvalues() {
        let url = URL(string: "https://any-url.com")!
        let urlResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let httpUrlResponse = HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyData = Data(base64Encoded: "any-data")
        let anyError = NSError(domain: "any-error", code: 0, userInfo: nil)
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: urlResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: httpUrlResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: urlResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: httpUrlResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: urlResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: httpUrlResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: urlResponse, error: nil))
    }
    
    
    //MARK: Helpers
    
    private func anyUrl() -> URL {
        return URL(string: "http://any-given-url.com")!
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        trackMemoryLeak(instance: sut)
        return sut
    }
    
    private func resultErrorFor(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil, file: StaticString = #file, line: UInt = #line) -> Error? {
        var receivedError: Error?
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "wait for completion")
        sut.get(from: anyUrl(), completion:  { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure but got failure \(result) instead", file: file, line:line)
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
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
            requestObserver = nil
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
