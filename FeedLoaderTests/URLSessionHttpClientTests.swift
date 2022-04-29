//
//  URLSessionHttpClientTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 29/04/22.
//

import XCTest
@testable import FeedLoader

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}


class URLSessionHttpClient {
    private let session: HTTPSession
    
    init(urlSession: HTTPSession) {
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
    
    func test_getFromURL_validateResume() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        
        session.stub(for: url, with: task)
        
        let sut = URLSessionHttpClient(urlSession: session)
        sut.get(from: url, completion: { _ in })
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURK_failOnRequestError() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        
        let error = NSError(domain: "Any error", code: 1)
        session.stub(for: url, with: task, error: error)
        let sut = URLSessionHttpClient(urlSession: session)
        
        let exp = expectation(description: "fail request error")
        sut.get(from: url, completion:  { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail()
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    
    //MARK: Helpers
    private class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionDataTask
            let error: Error?
        }
        func stub(for url: URL, with task: HTTPSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Cound't find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: HTTPSessionDataTask {
        func resume() {
            
        }
    }
    private class URLSessionDataTaskSpy: HTTPSessionDataTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
