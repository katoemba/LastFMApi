//
//  File.swift
//  
//
//  Created by Berrie Kremers on 23/02/2020.
//

import Foundation
import RxSwift

public struct ArtistInfo {
    public var name: String = ""
    public var mbid: String? = nil
    public var url: String = ""
    public var biography: String = ""
    public var shortBiography: String? = nil
}

extension LastFMApi {
    public typealias ArtisInfoResult = Swift.Result<ArtistInfo, ApiError>
    
    /// Retrieve a biography of an artist
    /// - Parameter artist: artist name
    /// - Returns: an observable result giving either a .success(ArtistInfo) or .failure
    public func info(artist: String) -> Observable<ArtisInfoResult> {
        struct Root: Decodable {
            var artist: Artist?
        }
        struct Artist: Decodable {
            var name: String
            var mbid: String?
            var url: String?
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
        
        return dataGetRequest(parameters: parameters)
            .map({ data -> ArtisInfoResult in
                let root = try JSONDecoder().decode(Root.self, from: data)
                
                guard let artist = root.artist else { return .failure(.notFound) }
                let biography = artist.bio?.content ?? ""
                let biographyComponents = biography.components(separatedBy: " <a href")
                let shortBiography = artist.bio?.summary ?? ""
                let shortBiographyComponents = shortBiography.components(separatedBy: " <a href")

                guard let url = artist.url, biographyComponents.count > 0, biographyComponents[0] != "" else { return .failure(.missingData) }
                return .success(ArtistInfo(name: artist.name,
                                           mbid: artist.mbid,
                                           url: url,
                                           biography: biographyComponents[0],
                                           shortBiography: shortBiographyComponents.count > 0 ? shortBiographyComponents[0] : nil))
            })
            .catch({ (error) -> Observable<ArtisInfoResult> in
                print(error)
                return Observable.just(.failure(.invalidResponse))
            })
    }


    public typealias SimilarArtistsResult = Swift.Result<[String], ApiError>
    
    /// Retrieve a biography of an artist
    /// - Parameter artist: artist name
    /// - Returns: an observable ArtistInfoResult giving either a .success or .failure

    /// Retrieve an array of similar artists
    /// - Parameters:
    ///   - artist: the artist to search for
    ///   - limit: the maximum number of similar artists to return (default = 20)
    /// - Returns: an observable result giving either a .success([String]) or .failure
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
                          "limit": "\(limit)",
                          "api_key": apiKey,
                          "format": "json"]
        
        return dataGetRequest(parameters: parameters)
            .map({ data -> SimilarArtistsResult in
                let root = try JSONDecoder().decode(Root.self, from: data)
                
                guard let artists = root.similarartists?.artist else { return .failure(.notFound) }

                return .success(artists.map { $0.name })
            })
            .catch({ (error) -> Observable<SimilarArtistsResult> in
                print(error)
                return Observable.just(.failure(.invalidResponse))
            })
    }
}
