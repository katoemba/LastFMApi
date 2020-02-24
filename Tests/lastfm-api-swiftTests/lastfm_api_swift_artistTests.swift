import XCTest
import RxSwift
import RxBlocking
@testable import lastfm_api_swift

final class lastfm_api_swift_artistTests: XCTestCase {
    private var apiKey = ""
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let envVar = getenv("LASTFM_API_KEY") else { fatalError("Environment variable LASTFM_API_KEY missing.") }
        apiKey = String(cString: envVar)
    }
    
    func testArtistInfo() {
        let lastfm = LastFMApi(apiKey: apiKey)
        let result = lastfm.info(artist: "Destroyer")
            .toBlocking(timeout: 5.0)
            .materialize()
        
        switch result {
        case .completed(let results):
            let result = results[0]
            switch result {
            case let .success(artistInfo):
                XCTAssert(artistInfo.name == "Destroyer")
                XCTAssert(artistInfo.mbid != "")
                XCTAssert(artistInfo.bio != "")
            case let .failure(error):
                XCTAssert(false, "\(error)")
            }
        case let .failed(_, error):
            XCTAssert(false, "\(error)")
        }
    }

    func testCorrectedArtistInfo() {
        let lastfm = LastFMApi(apiKey: apiKey)
        let result = lastfm.info(artist: "Taylor Swit")
            .toBlocking(timeout: 5.0)
            .materialize()
        
        switch result {
        case .completed(let results):
            let result = results[0]
            switch result {
            case let .success(artistInfo):
                XCTAssert(artistInfo.name == "Taylor Swift")
                XCTAssert(artistInfo.mbid != "")
                XCTAssert(artistInfo.bio != "")
            case let .failure(error):
                XCTAssert(false, "\(error)")
            }
        case let .failed(_, error):
            XCTAssert(false, "\(error)")
        }
    }
    
    func testSimilarArtists() {
        let lastfm = LastFMApi(apiKey: apiKey)
        let result = lastfm.similarArtists(artist: "Destroyer", limit: 8)
            .toBlocking(timeout: 5.0)
            .materialize()
        
        switch result {
        case .completed(let results):
            let result = results[0]
            switch result {
            case let .success(artists):
                XCTAssert(artists.count == 8)
            case let .failure(error):
                XCTAssert(false, "\(error)")
            }
        case let .failed(_, error):
            XCTAssert(false, "\(error)")
        }
    }

    static var allTests = [
        ("testArtistInfo", testArtistInfo),
        ("testCorrectedArtistInfo", testCorrectedArtistInfo),
        ("testSimilarArtists", testSimilarArtists),
    ]
}
