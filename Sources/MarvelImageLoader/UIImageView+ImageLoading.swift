import ObjectiveC
import UIKit

private enum AssociatedKeys {
    static var task = "MarvelImageLoader.task"
    static var representedURL = "MarvelImageLoader.representedURL"
}

public extension UIImageView {
    func setImage(
        from url: URL?,
        placeholder: UIImage? = nil,
        loader: ImageLoading = ImageLoader.shared
    ) {
        cancelImageLoad()
        image = placeholder

        guard let url else { return }
        objc_setAssociatedObject(self, &AssociatedKeys.representedURL, url as NSURL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let task = loader.loadImage(from: url) { [weak self] result in
            guard let self,
                  let representedURL = objc_getAssociatedObject(self, &AssociatedKeys.representedURL) as? NSURL,
                  representedURL == url as NSURL else { return }

            if case .success(let image) = result {
                self.image = image
            }
            objc_setAssociatedObject(self, &AssociatedKeys.task, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        objc_setAssociatedObject(self, &AssociatedKeys.task, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func cancelImageLoad() {
        let task = objc_getAssociatedObject(self, &AssociatedKeys.task) as? ImageLoadTask
        task?.cancel()
        objc_setAssociatedObject(self, &AssociatedKeys.task, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.representedURL, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
