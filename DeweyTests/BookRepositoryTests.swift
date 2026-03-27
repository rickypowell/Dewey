import Foundation
import Testing
@testable import Dewey

private class MockBookFetcher: BookFetcher {
    var result: BookPagePayload = .default
    var error: (any Error)?

    func fetch(_ query: BookQuery) async throws -> BookPagePayload {
        if let error { throw error }
        return result
    }

    func buildFetchURL(_ query: BookQuery) -> URL? { nil }
    func buildBookCoverImageURL(_ coverI: Int?) -> URL? { nil }
}

struct BookRepositoryTests {

    @Test func statusIsInitialBeforeFetch() {
        let repo = BookRepository(bookFetcher: MockBookFetcher(), bookStore: NoopBookStore())
        #expect(repo.status == .initial)
    }

    @Test func statusIsIdleAfterSuccessfulFetch() async {
        let fetcher = MockBookFetcher()
        let repo = BookRepository(bookFetcher: fetcher, bookStore: NoopBookStore())

        await repo.fetchBooks(query: "swift")

        #expect(repo.status == .idle)
    }

    @Test func statusIsIdleAfterFailedFetch() async {
        let fetcher = MockBookFetcher()
        fetcher.error = URLError(.badServerResponse)
        let repo = BookRepository(bookFetcher: fetcher, bookStore: NoopBookStore())

        await repo.fetchBooks(query: "swift")

        #expect(repo.status == .idle)
    }

    @Test func statusIsInitialOnClonedRepository() {
        let original = BookRepository(bookFetcher: MockBookFetcher(), bookStore: NoopBookStore())
        let cloned = original.clone()

        #expect(cloned.status == .initial)
    }
}
