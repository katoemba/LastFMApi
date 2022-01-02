import Foundation
import RxSwift

public class LastFMApi {
    public enum ApiError: Error {
        case notFound
        case missingData
        case invalidRequest
        case invalidResponse
    }

    let apiKey: String
    private static let url = "https://ws.audioscrobbler.com/2.0/"
    private let userAgent: String
    
    /// Initialize a LastFMApi object
    /// - Parameters:
    ///   - apiKey: your last.fm api key
    ///   - userAgent: the userAgent to report to last.fm
    public init(apiKey: String, userAgent: String) {
        self.apiKey = apiKey
        self.userAgent = userAgent
    }
    
    func dataGetRequest(parameters: [String: String]) -> Observable<Data> {
        Observable.create { observer in
            var components = URLComponents(string: Self.url)!
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }

            var request = URLRequest(url: components.url!, timeoutInterval: 3)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("userAgent", forHTTPHeaderField: "User-Agent")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    observer.onNext(data)
                    observer.onCompleted()
                }
                else {
                    observer.onError(error!)
                }
            }

            task.resume()
            return Disposables.create()
        }
    }
}

