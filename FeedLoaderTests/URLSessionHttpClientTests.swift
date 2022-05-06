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
        session.dataTask(with: url) { data, response, error in
            if let err = error {
                completion(.failure(err))
            }
            else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response ))
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
    
    override func tearDown() {
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

        makeSUT().get(from: url) { _ in }

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

        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyUrlResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyUrlResponse(), error: nil))
    }
    
    func test_getFromURL_succeedOnHttpUrlResponseWithValidData() {
        let data = anyData()
        let httpUrlResponse = anyHttpUrlResponse()
        let receivedValues = resultValuesFor(data: data, response: httpUrlResponse, error: nil)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.reponse.url, httpUrlResponse.url)
        XCTAssertEqual(receivedValues?.reponse.statusCode, httpUrlResponse.statusCode)
            
    }
    
    func test_getFromURL_succeedWithEmptyDataOnHttpUrlResponseWithValidData() {
        let httpUrlResponse = anyHttpUrlResponse()
        let receivedValues = resultValuesFor(data: nil, response: httpUrlResponse, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.reponse.url, httpUrlResponse.url)
        XCTAssertEqual(receivedValues?.reponse.statusCode, httpUrlResponse.statusCode)
            
    }
    
    
    //MARK: Helpers
    
    private func anyError() -> NSError {
        return NSError(domain: "any-error", code: 0, userInfo: nil)
    }
    
    private func anyData() -> Data {
        return Data("any-data".utf8)
    }
    
    private func anyUrl() -> URL {
        return URL(string: "http://any-given-url.com")!
    }
    
    private func anyUrlResponse() -> URLResponse {
        return URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHttpUrlResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        trackMemoryLeak(instance: sut)
        return sut
    }
    
    private func resultFor(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        var receivedResult: HTTPClientResult!
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "wait for completion")
        sut.get(from: anyUrl(), completion:  { result in
            receivedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func resultErrorFor(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil, file: StaticString = #file, line: UInt = #line) -> Error? {
        var receivedError: Error?
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case let .failure(error):
            receivedError = error
        default:
            XCTFail("Expected failure but got failure \(result) instead", file: file, line:line)
            
        }
            
        return receivedError
    }
    
    private func resultValuesFor(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil, file: StaticString = #file, line: UInt = #line) -> (data: Data, reponse: HTTPURLResponse)? {
        var receivedValues: (data: Data, reponse: HTTPURLResponse)?
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case let .success(data, response):
            receivedValues = (data, response)
        default:
            XCTFail("Expected success but got \(result) instead", file: file, line:line)
        }
        return receivedValues
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
