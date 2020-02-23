import XCTest
import RxSwift
import RxBlocking
@testable import lastfm_api_swift

final class lastfm_api_swiftTests: XCTestCase {
    private var apiKey = ""
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let envVar = getenv("LASTFM_API_KEY") else { fatalError("Environment variable LASTFM_API_KEY missing.") }
        apiKey = String(cString: envVar)
    }
    
    func testArtistInfo() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let lastfm = LastFMApi(apiKey: apiKey)
        let result = lastfm.info(artist: "Destroyer")
            .toBlocking(timeout: 5.0)
            .materialize()
        
        switch result {
        case .completed(let infos):
            let artistInfo = infos[0]
            XCTAssert(artistInfo.name == "Destroyer")
            XCTAssert(artistInfo.bio != "")
            XCTAssert(artistInfo.similarArtists.count > 0)
        default:
            XCTAssert(false, "info(artist) failed")
        }
    }

    func testCorrectedArtistInfo() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let lastfm = LastFMApi(apiKey: apiKey)
        let result = lastfm.info(artist: "Taylor Swit")
            .toBlocking(timeout: 5.0)
            .materialize()
        
        switch result {
        case .completed(let infos):
            let artistInfo = infos[0]
            XCTAssert(artistInfo.name == "Taylor Swift")
            XCTAssert(artistInfo.bio != "")
            XCTAssert(artistInfo.similarArtists.count > 0)
        default:
            XCTAssert(false, "corrected info(artist) failed")
        }
    }

    static var allTests = [
        ("testArtistInfo", testArtistInfo),
        ("testCorrectedArtistInfo", testCorrectedArtistInfo),
    ]
}
