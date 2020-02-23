//
//  File.swift
//  
//
//  Created by Berrie Kremers on 23/02/2020.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

extension LastFMApi {
    public typealias ArtisInfoResult = Swift.Result<ArtistInfo, ApiError>
    public func info(artist: String) -> Observable<ArtisInfoResult> {
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
        
        return dataPostRequest(parameters: parameters)
            .map({ result -> ArtisInfoResult in
                switch result {
                case let .success(_, data):
                    let root = try JSONDecoder().decode(Root.self, from: data)
                    
                    return .success(ArtistInfo(name: root.artist.name,
                                             bio: root.artist.bio.content,
                                             similarArtists: root.artist.similar.artist.map({ (artist) -> String in
                                                artist.name
                                             })))
                case let .failure(error):
                    return .failure(error)
                }
            })
            .catchError({ (error) -> Observable<ArtisInfoResult> in
                print(error)
                return Observable.just(.failure(.notFound))
            })
    }
}
