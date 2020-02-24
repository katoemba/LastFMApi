//
//  File.swift
//
//
//  Created by Berrie Kremers on 23/02/2020.
//

import Foundation
import RxSwift

public struct AlbumInfo {
    var name: String = ""
    var description: String = ""
}

extension LastFMApi {
    public typealias AlbumInfoResult = Swift.Result<AlbumInfo, ApiError>
    public func info(album: String, artist: String) -> Observable<AlbumInfoResult> {
        struct Root: Decodable {
            var album: Album?
        }
        struct Album: Decodable {
            var name: String
            var artist: String
            var wiki: Wiki?
        }
        struct Wiki: Decodable {
            var published: String?
            var summary: String?
            var content: String?
        }
        
        let parameters = ["method": "album.getinfo",
                          "artist": artist,
                          "album": album,
                          "api_key": apiKey,
                          "format": "json"]
        
        return dataPostRequest(parameters: parameters)
            .map({ result -> AlbumInfoResult in
                switch result {
                case let .success(_, data):
                    let root = try JSONDecoder().decode(Root.self, from: data)
                    
                    guard let album = root.album else { return .failure(.notFound) }
                    guard let description = album.wiki?.content ?? album.wiki?.summary else { return .failure(.missingData) }

                    return .success(AlbumInfo(name: album.name,
                                              description: description))
                case let .failure(error):
                    return .failure(error)
                }
            })
            .catchError({ (error) -> Observable<AlbumInfoResult> in
                print(error)
                return Observable.just(.failure(.invalidResponse))
            })
    }
}
