import Foundation

/// Interface to fetch Book data
protocol BookFetcher {
    /// Executes the fetch given the query
    func fetch(_ query: BookQuery) async throws -> BookPagePayload
    /// Builds and returns the URL expected to be used in the fetch
    func buildFetchURL(_ query: BookQuery) -> URL?
    /// Builds and returns the URL expected for a book cover image to be displayed
    /// in the UI.
    func buildBookCoverImageURL(_ book: BookPayload) -> URL?
}

struct BookQuery {
    /// The solr query
    let q: String
    /// The fields to get back from solr.
    let fields: [BookPayload.CodingKeys]
    /// Use for pagination
    let limit: UInt64
    /// use for pagination
    let offset: UInt64
}
