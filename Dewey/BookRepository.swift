import Foundation

/// This Observable can fetch books using it's given `BookFetcher`.
/// The data is stored in `var book: [BookPayload]` and is initially empty.
@Observable
class BookRepository {
    private(set) var books: [BookPayload] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let bookFetcher: any BookFetcher

    init(bookFetcher: any BookFetcher) {
        self.bookFetcher = bookFetcher
    }

    func fetchBooks(query: String) async {
        isLoading = true
        errorMessage = nil

        let bookQuery = BookQuery(
            q: query,
            fields: [.title, .authorName, .authorKey, .isbn, .coverI, .firstPublishYear],
            limit: 20,
            offset: 0
        )

        do {
            let page = try await bookFetcher.fetch(bookQuery)
            books = page.docs
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func coverImageURL(for book: BookPayload) -> URL? {
        bookFetcher.buildBookCoverImageURL(book)
    }
}
