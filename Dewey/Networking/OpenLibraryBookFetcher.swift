import Foundation

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

        let decoder = JSONDecoder()
        return try decoder.decode(BookPagePayload.self, from: data)
    }

    /// Builds the URL for the `fetch(_:) async throws -> BookPagePayload` to use.
    /// This includes the proper query parameters:
    /// - `q` for the given query
    /// - `fields` for the correctly expected fields to retrieve
    /// - `limit` and `offset` for pagination
    func buildFetchURL(_ query: BookQuery) -> URL? {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query.q),
            URLQueryItem(name: "fields", value: query.fields.map(\.rawValue).joined(separator: ",")),
            URLQueryItem(name: "limit", value: String(query.limit)),
            URLQueryItem(name: "offset", value: String(query.offset))
        ]
        return components.url
    }

    func buildBookCoverImageURL(_ book: BookPayload) -> URL? {
        guard let coverI = book.coverI else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverI)-M.jpg")
    }
}
