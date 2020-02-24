//
//  File.swift
//  
//
//  Created by Berrie Kremers on 23/02/2020.
//

import Foundation
import RxSwift

public struct ArtistInfo {
    var name: String = ""
    var mbid: String = ""
    var bio: String = ""
}

extension LastFMApi {
    public typealias ArtisInfoResult = Swift.Result<ArtistInfo, ApiError>
    public func info(artist: String) -> Observable<ArtisInfoResult> {
        struct Root: Decodable {
            var artist: Artist?
        }
        struct Artist: Decodable {
            var name: String
            var mbid: String?
            var bio: Biography?
        }
        struct Biography: Decodable {
            var content: String?
            var summary: String?
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
                    
                    guard let artist = root.artist else { return .failure(.notFound) }
                    guard let bio = artist.bio?.content ?? artist.bio?.summary else { return .failure(.missingData) }

                    return .success(ArtistInfo(name: artist.name,
                                               mbid: artist.mbid ?? "",
                                               bio: bio))
                case let .failure(error):
                    return .failure(error)
                }
            })
            .catchError({ (error) -> Observable<ArtisInfoResult> in
                print(error)
                return Observable.just(.failure(.invalidResponse))
            })
    }


    public typealias SimilarArtistsResult = Swift.Result<[String], ApiError>
    public func similarArtists(artist: String, limit: Int = 20) -> Observable<SimilarArtistsResult> {
        struct Root: Decodable {
            var similarartists: SimilarArtist?
        }
        struct SimilarArtist: Decodable {
            var artist: [Artist]
        }
        struct Artist: Decodable {
            var name: String
            var mbid: String?
            var match: String?
        }
        
        let parameters = ["method": "artist.getsimilar",
                          "artist": artist,
                          "autocorrect": "1",
                          "limit": limit,
                          "api_key": apiKey,
        "format": "json"] as [String: Any]
        
        return dataPostRequest(parameters: parameters)
            .map({ result -> SimilarArtistsResult in
                switch result {
                case let .success(_, data):
                    let root = try JSONDecoder().decode(Root.self, from: data)
                    
                    guard let artists = root.similarartists?.artist else { return .failure(.notFound) }

                    return .success(artists.map { $0.name })
                case let .failure(error):
                    return .failure(error)
                }
            })
            .catchError({ (error) -> Observable<SimilarArtistsResult> in
                print(error)
                return Observable.just(.failure(.invalidResponse))
            })
    }
}
