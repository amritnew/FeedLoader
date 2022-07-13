//
//  SharedTestHelpers.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 09/06/22.
//

import Foundation


func anyError() -> NSError {
    return NSError(domain: "any-error", code: 0, userInfo: nil)
}

func anyUrl() -> URL {
    return URL(string: "http://any-given-url.com")!
}
