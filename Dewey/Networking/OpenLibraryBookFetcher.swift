import Foundation
import os
import Playgrounds

#Playground {
    let fetcher = OpenLibraryBookFetcher(networkData: LiveNetworkData())
    let query = BookQuery(q: "title:The Odessey of Homer", fields: [.title, .authorName, .authorKey, .isbn, .subject], limit: 15, offset: 0)
    do {
        let result = try await fetcher.fetch(query)
        _ = result.docs
    } catch {
        _ = error
    }
}

fileprivate let logger = Logger(subsystem: "com.ricky-powell.Dewey", category: "OpenLibraryBookFetcher")

/// This knows how to fetch from Open Library using the search API.
/// This is a concrete implmentation of the `BookFetcher` protocol.
/// Initialize this with a `NetworkData` implementation.
class OpenLibraryBookFetcher: BookFetcher {
    private let networkData: any NetworkData
    private let baseURL = "https://openlibrary.org/search.json"

    init(networkData: any NetworkData) {
        self.networkData = networkData
    }

    /// Uses the given `NetworkData` to fetch given the `URL` from `buildFetchURL`.
    /// If the network data is retrieved successfully, then the `Data` is decoded
    /// for the `BookPagePayload` object and returned from this method.
    func fetch(_ query: BookQuery) async throws -> BookPagePayload {
        guard let url = buildFetchURL(query) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await networkData.data(from: url)
        
        #if DEBUG
        if let str = String(bytes: data, encoding: .utf8) {
            logger.debug("JSON request: \(url)")
            logger.debug("JSON response: \(str)")
        }
        #endif

        let decoder = JSONDecoder()
        return try decoder.decode(BookPagePayload.self, from: data)
    }

    /// Builds the URL for the `fetch(_:) async throws -> BookPagePayload` to use.
    /// This includes the proper query parameters:
    /// - `q` for the given query
    /// - `fields` for the correctly expected fields to retrieve
    /// - `limit` and `offset` for pagination
    func buildFetchURL(_ query: BookQuery) -> URL? {
        // SAFETY: `baseURL` is verified the correct format
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query.q),
            URLQueryItem(name: "fields", value: query.fields.map(\.rawValue).joined(separator: ",")),
            URLQueryItem(name: "limit", value: String(query.limit)),
            URLQueryItem(name: "offset", value: String(query.offset))
        ]
        return components.url
    }

    /// Assumes that we will always be fetching medium ("M") size images
    /// and the key is always "id" which corresponds to the `cover_i`.
    func buildBookCoverImageURL(_ coverI: Int?) -> URL? {
        guard let coverI else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverI)-M.jpg")
    }
}
