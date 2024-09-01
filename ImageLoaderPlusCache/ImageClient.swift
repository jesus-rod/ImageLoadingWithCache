//
//  ImageClient.swift
//  ImageLoadingWithCache
//
//  Created by JesusR on 01.09.24.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

protocol PlatformImage {
    init?(named name: String)
    init?(data: Data)
}

#if os(iOS)
extension UIImage: PlatformImage {}
public typealias Image = UIImage
public typealias ImageView = UIImageView
#elseif os(macOS)
extension NSImage: PlatformImage {}
public typealias Image = NSImage
public typealias ImageView = NSImageView

#endif

protocol ImageClientProtocol {
    func downloadImage(fromURL url: URL, completion: @escaping (Result<Image, NetworkError>) -> Void) -> NetworkTask?
    func setImage(on imageView: ImageView, fromURL url: URL, withPlaceholder placeholder: Image?)
}

public class ImageClient {
    public static let shared = ImageClient(session: URLSession.shared)
    
    let session: URLSessionProtocol
    var cache = NSCache<NSString, Image>()
    var runningTasks = [ImageView: NetworkTask]()
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
}

extension ImageClient: ImageClientProtocol {
    
    internal func downloadImage(fromURL url: URL, completion: @escaping (Result<Image, NetworkError>) -> Void) -> NetworkTask? {
        
        let cacheKey = NSString(string: url.absoluteString)
        if let image = cache.object(forKey: cacheKey) {
            completion(.success(image))
            return nil
        }
        
        let task = session.makeDataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            
            if let data = data, let image = Image(data: data) {
                self.cache.setObject(image, forKey: cacheKey)
                completion(.success(image))
                return
            } else {
                completion(.failure(.noData))
                return
            }
        }
        task.resume()
        return task
    }
    
    public func setImage(on imageView: ImageView, fromURL url: URL, withPlaceholder placeholder: Image?) {
        
        runningTasks[imageView]?.cancel()
        imageView.image = placeholder
        
        runningTasks[imageView] = downloadImage(fromURL: url) { [weak self] result in
            guard let self = self else { return }
            self.runningTasks[imageView] = nil
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    imageView.image = image
                }
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        }
    }
    
}
