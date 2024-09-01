# ``ImageLoaderPlusCache``

This is a framework that allows downloading images through a URL. It works for both iOS and MacOS.

## Overview

It uses an in-memory cache making use of:

1. **NSCache**: Apple tipically encourages developers to use NSCache over dictionaries especially when we expect to store data with a large memory footprint. As shown during the [iOS Memory Deep Dive](https://developer.apple.com/videos/play/wwdc2018/416/) at WWDC 2018. The NSCache class incorporates various auto-eviction policies and is also configurable through countLimit and totalCostLimit.

2. A dictionary to cancel ongoing tasks: This is usually fine for smaller datasets and preferable for non class types.

This client is designed to work for both iOS and MacOS and therefore it was built using an abstraction *PlatformImage* which will work along with conditional compilation directives to seamlessly integrate in either of these two platforms.

Moreover this design allows for easy extension to other platforms without touching the main logic and functionality to load and cache images. See code snippet below for details.

```
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
//  <-------- Add another platform here if required
#endif
```

## Testing

- URLSession and URLSessionTask were abstracted through protocols. Therefore, creating a MockURLSession that does not make actual network requests is possible.
- We then leverage our MockURLSession to test our ImageClient in **ImageClientTests.swift** Some useful tests included here are:
1. Testing that resume() is called. A very common mistake is to forget to call resume() after a task is created.
2. Test images being stored in cache
3. Test URL Task being cached
4. Test cache eviction for both images and URL Tasks
5. Test correct completion for image loaded and error returned
6. And several more tests making 15 cases in total.


## Next steps and room for improvement

- Improved error handling: At this moment, the enum NetworkError is very concise and limiting the possible errors that the users can interact with. We can add more errors such as serverError, notFound, timeout, noInternet.
- Improve test suite: Add test cases to ImageClientTests.swift for serverError, notFound, timeout, noInternet, etc.
- Allow for injection of parameters used by NSCache such as countLimit and totalCostLimit.


## Notes from the author

1. The ImageLoaderPlusCache framework is the focus behind this exercise. Go to that folder to see the Image Client implementation.
2. If you need to verify this apps builds for both iOS and MacOS select the framework **ImageLoaderPlusCache** in Xcode and change the platform to either iOS/MacOS
4. The app containing the framework is for testing purposes only. 
5. Questions, comments or concerns? Let's talk. 
