//
//  File.swift
//
//
//  Created by Berrie Kremers on 23/02/2020.
//

import Foundation
import RxSwift

public struct AlbumInfo {
    public var name: String = ""
    public var url: String = ""
    public var description: String = ""
    public var shortDescription: String? = nil
}

extension LastFMApi {
    public typealias AlbumInfoResult = Swift.Result<AlbumInfo, ApiError>
    
    /// Retrieve a description of an album
    /// - Parameters:
    ///   - album: album title
    ///   - artist: artist name
    /// - Returns: an observable result giving either a .success(AlbumInfo) or .failure
    public func info(album: String, artist: String) -> Observable<AlbumInfoResult> {
        struct Root: Decodable {
            var album: Album?
        }
        struct Album: Decodable {
            var name: String
            var artist: String
            var url: String?
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
        
        return dataGetRequest(parameters: parameters)
            .map({ data -> AlbumInfoResult in
                let root = try JSONDecoder().decode(Root.self, from: data)
                
                guard let album = root.album else { return .failure(.notFound) }
                let description = album.wiki?.content ?? ""
                let descriptionComponents = description.components(separatedBy: " <a href")
                let summary = album.wiki?.summary ?? ""
                let summaryComponents = summary.components(separatedBy: " <a href")

                guard let url = album.url, descriptionComponents.count > 0, descriptionComponents[0] != "" else { return .failure(.missingData) }
                return .success(AlbumInfo(name: album.name,
                                          url: url,
                                          description: descriptionComponents[0],
                                          shortDescription: summaryComponents.count > 0 ? summaryComponents[0] : nil))
            })
            .catch({ (error) -> Observable<AlbumInfoResult> in
                print(error)
                return Observable.just(.failure(.invalidResponse))
            })
    }
}
