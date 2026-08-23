import XCTest
@testable import MarvelImageLoader

final class ImageLoaderTests: XCTestCase {
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        URLProtocolStub.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        session = URLSession(configuration: configuration)
    }

    override func tearDown() {
        session.invalidateAndCancel()
        session = nil
        super.tearDown()
    }

    func testLoadsValidImageOnMainThread() {
        URLProtocolStub.response = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.data = makeImageData()
        let loader = ImageLoader(session: session)
        let expectation = expectation(description: "image loaded")

        loader.loadImage(from: testURL) { result in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertNotNil(try? result.get())
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testReturnsInvalidResponseForHTTPError() {
        URLProtocolStub.response = HTTPURLResponse(url: testURL, statusCode: 500, httpVersion: nil, headerFields: nil)
        let loader = ImageLoader(session: session)
        let expectation = expectation(description: "request failed")

        loader.loadImage(from: testURL) { result in
            XCTAssertEqual(try? result.get(), nil)
            if case .failure(let error) = result {
                XCTAssertEqual(error, .invalidResponse)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testUsesMemoryCacheAfterFirstRequest() {
        URLProtocolStub.response = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.data = makeImageData()
        let loader = ImageLoader(session: session)
        let expectation = expectation(description: "image loaded twice")
        expectation.expectedFulfillmentCount = 2

        loader.loadImage(from: testURL) { firstResult in
            XCTAssertNotNil(try? firstResult.get())
            expectation.fulfill()
            loader.loadImage(from: self.testURL) { secondResult in
                XCTAssertNotNil(try? secondResult.get())
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(URLProtocolStub.requestCount, 1)
    }

    private let testURL = URL(string: "https://example.com/image.png")!

    private func makeImageData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }.pngData()!
    }
}

private final class URLProtocolStub: URLProtocol {
    static var data: Data?
    static var response: URLResponse?
    static var error: Error?
    static var requestCount = 0

    static func reset() {
        data = nil
        response = nil
        error = nil
        requestCount = 0
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.requestCount += 1
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        if let response = Self.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = Self.data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
