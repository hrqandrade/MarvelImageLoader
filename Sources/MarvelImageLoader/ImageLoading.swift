import UIKit

public protocol ImageLoadTask: AnyObject {
    func cancel()
}

public protocol ImageLoading {
    @discardableResult
    func loadImage(
        from url: URL,
        completion: @escaping (Result<UIImage, ImageLoadingError>) -> Void
    ) -> ImageLoadTask?
}

public enum ImageLoadingError: Error, Equatable {
    case transport
    case invalidResponse
    case invalidData
}

extension URLSessionDataTask: ImageLoadTask {}
