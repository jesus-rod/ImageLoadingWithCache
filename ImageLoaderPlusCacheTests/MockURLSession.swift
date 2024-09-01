//
//  MockURLSession.swift
//  ImageLoadingWithCacheTests
//
//  Created by JesusR on 01.09.24.
//

import Foundation
@testable import ImageLoaderPlusCache

class MockURLSession: URLSessionProtocol {

    func makeDataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> NetworkTask {
        return MockURLSessionTask(
            completionHandler: completionHandler,
            url: url)
    }
}

class MockURLSessionTask: NetworkTask {

    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    var url: URL

    init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void, url: URL) {
        self.completionHandler = completionHandler
        self.url = url
    }

    var calledCancel = false
    func cancel() {
        calledCancel = true
    }

    var calledResume = false
    func resume() {
        calledResume = true
    }
}
