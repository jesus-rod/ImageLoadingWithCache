//
//  ImageLoadingWithCacheTests.swift
//  ImageLoadingWithCacheTests
//
//  Created by JesusR on 01.09.24.
//

import XCTest
@testable import ImageLoaderPlusCache

final class ImageClientTests: XCTestCase {
    
    var mockSession: MockURLSession!
    var sut: ImageClient!
    var service: ImageClientProtocol {
        return sut as ImageClientProtocol
    }
    var url: URL!
    
    var receivedTask: MockURLSessionTask?
    var receivedError: NetworkError?
    var receivedImage: Image?
    var expectedImage: Image!
    var expectedError: NetworkError!
    
    var imageView: ImageView!
    
    // MARK: - Test Lifecycle
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        url = URL(string: "https://example.com/image")!
        imageView = ImageView()
        sut = ImageClient(session: mockSession)
    }
    
    override func tearDown() {
        mockSession = nil
        url = nil
        sut = nil
        receivedTask = nil
        receivedError = nil
        receivedImage = nil
        expectedImage = nil
        expectedError = nil
        imageView = nil
        super.tearDown()
    }
    
    // MARK: - When
    func whenDownloadImage(
        image: Image? = nil, error: Error? = nil) {
            
            receivedTask = sut.downloadImage(fromURL: url) { result in
                switch result {
                case .success(let image):
                    self.receivedImage = image
                    self.receivedError = nil
                case .failure(let error):
                    self.receivedImage = nil
                    self.receivedError = error
                }
            } as? MockURLSessionTask
            
            guard let receivedTask = receivedTask else {
                return
            }
            if let image = image {
                receivedTask.completionHandler(
                    image.pngData(), nil, nil)
                
            } else if let error = error {
                receivedTask.completionHandler(nil, nil, error)
            }
        }
    
    func whenSetImage() {
        givenExpectedImage()
        sut.setImage(on: imageView, fromURL: url, withPlaceholder: nil)
        receivedTask = sut.runningTasks[imageView]
        as? MockURLSessionTask
        receivedTask?.completionHandler(
            expectedImage.pngData(), nil, nil)
    }
    
    // MARK: - Given
    func givenExpectedImage() {
        expectedImage = Image(named: "example_img")
    }
    
    func givenExpectedError() {
        expectedError = NetworkError.noData
    }
    
    func test_conformsTo_ImageProtocol() {
        XCTAssertTrue((sut as AnyObject) is ImageClientProtocol)
    }
    
    func test_imageService_declaresDownloadImage() {
        _ = service.downloadImage(fromURL: url) { _ in }
    }
    
    func test_imageService_declaresSetImageOnImageView() {
        // given
        let imageView = ImageView()
        let placeholder = Image(systemName: "photo.fill")
        
        // then
        service.setImage(on: imageView,
                         fromURL: url,
                         withPlaceholder: placeholder)
    }
    
    func test_downloadImage_createsExpectedTask() {
        // when
        whenDownloadImage()
        
        // then
        XCTAssertEqual(receivedTask?.url, url)
    }
    
    func test_downloadImage_callsResumeOnTask() {
        // when
        whenDownloadImage()
        
        // then
        XCTAssertTrue(receivedTask?.calledResume ?? false)
    }
    
    func test_downloadImage_givenImage_callsCompletionWithImage() {
        // given
        givenExpectedImage()
        
        // when
        whenDownloadImage(image: expectedImage)
        
        // then
        XCTAssertEqual(expectedImage.pngData(),
                       receivedImage?.pngData())
    }
    
    func test_downloadImage_givenError_callsCompletionWithError() {
        // given
        givenExpectedError()
        
        // when
        whenDownloadImage(error: expectedError)
        
        // then
        XCTAssertEqual(expectedError, receivedError)
    }
    
    func test_downloadImage_givenImage_cachesImage() {
        // given
        givenExpectedImage()
        
        // when
        whenDownloadImage(image: expectedImage)
        
        // then
        let cacheKey = NSString(string: url.absoluteString)
        XCTAssertEqual(sut.cache.object(forKey: cacheKey)!.pngData(), expectedImage.pngData())
    }
    
    func test_downloadImage_givenCachedImage_returnsNilDataTask() {
        // given
        givenExpectedImage()
        
        // when
        whenDownloadImage(image: expectedImage)
        whenDownloadImage(image: expectedImage)
        
        // then
        XCTAssertNil(receivedTask)
    }
    
    func test_downloadImage_givenCachedImage_callsCompletionWithImage() {
        // given
        givenExpectedImage()
        
        // when
        whenDownloadImage(image: expectedImage)
        receivedImage = nil
        
        whenDownloadImage(image: expectedImage)
        
        // then
        XCTAssertEqual(expectedImage.pngData(),
                       receivedImage?.pngData())
    }
    
    func test_setImageOnImageView_cancelsExistingDataTask() {
        // given
        let task = MockURLSessionTask(completionHandler: { _, _, _ in },
                                      url: url)
        sut.runningTasks[imageView] = task
        
        // when
        sut.setImage(on: imageView, fromURL: url, withPlaceholder: nil)
        
        // then
        XCTAssertTrue(task.calledCancel)
    }
    
    func test_setImageOnImageView_setsPlaceholderOnImageView() {
        // given
        givenExpectedImage()
        
        // when
        sut.setImage(on: imageView,
                     fromURL: url,
                     withPlaceholder: expectedImage)
        
        // then
        XCTAssertEqual(imageView.image?.pngData(),
                       expectedImage.pngData())
    }
    
    func test_setImageOnImageView_cachesTask() {
        // when
        sut.setImage(on: imageView,
                     fromURL: url,
                     withPlaceholder: nil)
        
        // then
        receivedTask = sut.runningTasks[imageView]
        as? MockURLSessionTask
        XCTAssertEqual(receivedTask?.url, url)
    }
    
    func test_setImageOnImageView_onCompletionRemovesCachedTask() {
        // when
        whenSetImage()
        
        // then
        XCTAssertNil(sut.runningTasks[imageView])
    }
    
    func test_setImageOnImageView_givenError_doesnSetImage() {
        // given
        givenExpectedImage()
        givenExpectedError()
        
        // when
        sut.setImage(on: imageView,
                     fromURL: url,
                     withPlaceholder: expectedImage)
        receivedTask = sut.runningTasks[imageView]
        as? MockURLSessionTask
        receivedTask?.completionHandler(nil, nil, expectedError)
        
        // then
        XCTAssertEqual(imageView.image?.pngData(),
                       expectedImage.pngData())
    }
}
