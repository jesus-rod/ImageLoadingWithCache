//
//  URLSessionProtocol.swift
//  ImageLoadingWithCache
//
//  Created by JesusR on 01.09.24.
//

import Foundation

protocol URLSessionProtocol: AnyObject {
    func makeDataTask(
        with url: URL,
        completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NetworkTask
}

protocol NetworkTask: AnyObject {
    func resume()
    func cancel()
}

extension URLSessionTask: NetworkTask { }

extension URLSession: URLSessionProtocol {
    func makeDataTask(with url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> NetworkTask {
        return dataTask(with: url, completionHandler: completionHandler)
    }
}
