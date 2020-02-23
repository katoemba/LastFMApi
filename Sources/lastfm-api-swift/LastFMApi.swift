import Foundation
import RxSwift
import RxAlamofire
import Alamofire

public struct ArtistInfo {
    var name: String = ""
    var bio: String = ""
    var similarArtists: [String] = []
}

public class LastFMApi {
    private let apiKey: String
    private let url = "https://ws.audioscrobbler.com/2.0/"
    private let encoding = URLEncoding.default
    private let headers = ["Content-Type": "application/json"]
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func info(artist: String) -> Observable<ArtistInfo> {
        struct Root: Decodable {
            var artist: Artist
        }
        struct Artist: Decodable {
            var name: String
            var mbid: String
            var bio: Biography
            var similar: SimilarArtists
        }
        struct Biography: Decodable {
            var content: String
            var summary: String
            //var published: Date
        }
        struct SimilarArtists: Decodable {
            var artist: [SimilarArtist]
        }
        struct SimilarArtist: Decodable {
            var name: String
            var url: String
        }
        
        let parameters = ["method": "artist.getinfo",
                          "artist": artist,
                          "autocorrect": "1",
                          "api_key": apiKey,
                          "format": "json"]
        
        return RxAlamofire.requestData(.get,
                                       url,
                                       parameters: parameters,
                                       encoding: encoding,
                                       headers: headers)
            .flatMapFirst( { (arg) -> Observable<(HTTPURLResponse, Data)> in
                let (response, data) = arg
                guard response.statusCode == 200, (response.mimeType ?? "").contains("json") else {
                    return Observable.empty()
                }
                return Observable.just((response, data))
            })
            .map({ (response, data) -> (ArtistInfo) in
                let root = try JSONDecoder().decode(Root.self, from: data)
                return ArtistInfo(name: root.artist.name,
                                  bio: root.artist.bio.content,
                                  similarArtists: root.artist.similar.artist.map({ (artist) -> String in
                                    artist.name
                                  }))
            })
            .catchError({ (error) -> Observable<ArtistInfo> in
                print(error)
                return Observable.empty()
            })
    }
}

