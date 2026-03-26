//
//  OpenLibraryBookFetcherTests.swift
//  DeweyTests
//
//  Created by Ricky Powell on 3/25/26.
//

import Foundation
import Testing
@testable import Dewey

class MockNetworkData: NetworkData {
    var mockData: Data = Data()
    var mockResponse: URLResponse = URLResponse()

    func data(from url: URL) async throws -> (Data, URLResponse) {
        (mockData, mockResponse)
    }
}

struct OpenLibraryBookFetcherTests {

    @Test func fetchDecodesResponse() async throws {
        let json = """
        {
            "num_found": 1,
            "start": 0,
            "docs": [
                {
                    "title": "The Lord of the Rings",
                    "author_name": ["J. R. R. Tolkien"],
                    "author_key": ["OL26320A"],
                    "isbn": ["0395647398"],
                    "subject": ["Fantasy fiction"],
                    "first_publish_year": 1954,
                    "cover_i": 14625765
                }
            ]
        }
        """.data(using: .utf8)!

        let mock = MockNetworkData()
        mock.mockData = json

        let fetcher = OpenLibraryBookFetcher(networkData: mock)
        let query = BookQuery(q: "lord of the rings", fields: [.title, .authorName, .authorKey, .isbn, .subject, .firstPublishYear, .coverI], limit: 10, offset: 0)

        let page = try await fetcher.fetch(query)

        #expect(page.numFound == 1)
        #expect(page.start == 0)
        #expect(page.docs.count == 1)
        #expect(page.docs[0].title == "The Lord of the Rings")
        #expect(page.docs[0].authorName == ["J. R. R. Tolkien"])
        #expect(page.docs[0].authorKey == ["OL26320A"])
        #expect(page.docs[0].isbn == ["0395647398"])
        #expect(page.docs[0].firstPublishYear == 1954)
        #expect(page.docs[0].coverI == 14625765)
    }

    @Test func buildFetchURLContainsQueryParameters() {
        let fetcher = OpenLibraryBookFetcher(networkData: MockNetworkData())
        let query = BookQuery(q: "dune", fields: [.title, .authorName], limit: 5, offset: 10)

        let url = fetcher.buildFetchURL(query)

        #expect(url != nil)
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems ?? []

        #expect(components.scheme == "https")
        #expect(components.host == "openlibrary.org")
        #expect(components.path == "/search.json")
        #expect(queryItems.contains(URLQueryItem(name: "q", value: "dune")))
        #expect(queryItems.contains(URLQueryItem(name: "fields", value: "title,author_name")))
        #expect(queryItems.contains(URLQueryItem(name: "limit", value: "5")))
        #expect(queryItems.contains(URLQueryItem(name: "offset", value: "10")))
    }

    @Test func buildBookCoverImageURL() {
        let fetcher = OpenLibraryBookFetcher(networkData: MockNetworkData())
        let book = BookPayload(
            title: "Dune",
            authorName: ["Frank Herbert"],
            authorKey: ["OL34221A"],
            isbn: ["0441172717"],
            subject: nil,
            firstPublishYear: 1965,
            coverI: 258027
        )

        let url = fetcher.buildBookCoverImageURL(book)

        #expect(url?.absoluteString == "https://covers.openlibrary.org/b/id/258027-M.jpg")
    }

    @Test func buildBookCoverImageURLReturnsNilWhenCoverIsMissing() {
        let fetcher = OpenLibraryBookFetcher(networkData: MockNetworkData())
        let book = BookPayload(
            title: "Dune",
            authorName: ["Frank Herbert"],
            authorKey: ["OL34221A"],
            isbn: ["0441172717"],
            subject: nil,
            firstPublishYear: 1965,
            coverI: nil
        )

        let url = fetcher.buildBookCoverImageURL(book)

        #expect(url == nil)
    }
}
