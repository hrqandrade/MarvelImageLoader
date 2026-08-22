import UIKit

public final class ImageLoader: ImageLoading {
    public static let shared = ImageLoader()

    private let session: URLSession
    private let cache: NSCache<NSURL, UIImage>

    public init(session: URLSession = .shared, cache: NSCache<NSURL, UIImage> = NSCache()) {
        self.session = session
        self.cache = cache
    }

    @discardableResult
    public func loadImage(
        from url: URL,
        completion: @escaping (Result<UIImage, ImageLoadingError>) -> Void
    ) -> ImageLoadTask? {
        if let image = cache.object(forKey: url as NSURL) {
            dispatchToMain { completion(.success(image)) }
            return nil
        }

        let task = session.dataTask(with: url) { [weak self] data, response, error in
            let result: Result<UIImage, ImageLoadingError>

            if error != nil {
                result = .failure(.transport)
            } else if let response = response as? HTTPURLResponse,
                      !(200 ..< 300).contains(response.statusCode) {
                result = .failure(.invalidResponse)
            } else if let data, let image = UIImage(data: data) {
                self?.cache.setObject(image, forKey: url as NSURL)
                result = .success(image)
            } else {
                result = .failure(.invalidData)
            }

            self?.dispatchToMain { completion(result) }
        }
        task.resume()
        return task
    }

    public func removeCachedImage(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }

    public func removeAllCachedImages() {
        cache.removeAllObjects()
    }

    private func dispatchToMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
