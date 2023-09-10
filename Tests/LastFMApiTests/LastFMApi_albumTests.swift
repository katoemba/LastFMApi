import XCTest
import RxSwift
import RxBlocking
@testable import LastFMApi

final class lastfm_api_swift_albumTests: XCTestCase {
    private var apiKey = ""
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let envVar = getenv("LASTFM_API_KEY") else { fatalError("Environment variable LASTFM_API_KEY missing.") }
        apiKey = String(cString: envVar)
    }
    
    func testAlbumInfo() {
        let lastfm = LastFMApi(apiKey: apiKey, userAgent: "TestAgent")
        let result = lastfm.info(album: "Lover", artist: "Taylor Swift")
            .toBlocking(timeout: 5.0)
            .materialize()
        
        switch result {
        case .completed(let results):
            let result = results[0]
            switch result {
            case let .success(albumInfo):
                XCTAssert(albumInfo.name == "Lover")
                XCTAssert(albumInfo.description != "")
                XCTAssert(albumInfo.shortDescription != "")
            case let .failure(error):
                XCTAssert(false, "\(error)")
            }
        case let .failed(_, error):
            XCTAssert(false, "\(error)")
        }
    }

    static var allTests = [
        ("testAlbumInfo", testAlbumInfo),
    ]
}
