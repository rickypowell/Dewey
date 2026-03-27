import Foundation
import SwiftData

/// This Observable can fetch books using it's given `BookFetcher`.
/// The data is stored in `var book: [BookPayload]` and is initially empty.
@Observable
class BookRepository {
    private(set) var books: [BookPayload] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let bookFetcher: any BookFetcher
    private let bookStore: any BookStore
    
    enum Token: CustomStringConvertible {
        case title(String)
        case author(String)
        case subject(String)
        
        var description: String {
            switch self {
            case .title(let str):
                "title:\"\(str)\""
            case .author(let str):
                "author:\"\(str)\""
            case .subject(let str):
                "subject:\"\(str)\""
            }
        }
    }

    init(bookFetcher: any BookFetcher, bookStore: any BookStore) {
        self.bookFetcher = bookFetcher
        self.bookStore = bookStore
    }
    
    /// This does not clone the data but the initialized `BookFetcher` and `BookStore` is passed to a new
    /// instance of `BookRepository`
    func clone() -> BookRepository {
        BookRepository(bookFetcher: bookFetcher, bookStore: bookStore)
    }
    
    func fetchBooks(tokens: [Token]) async {
        // results in String "{0.description} {N.description}"
        let merged = tokens.map { $0.description }.joined(separator: " ")
        await fetchBooks(query: merged)
    }

    func fetchBooks(query: String) async {
        books = []
        isLoading = true
        errorMessage = nil

        let bookQuery = BookQuery(
            q: query,
            fields: [.title, .authorName, .authorKey, .isbn, .coverI, .firstPublishYear, .subject],
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
    
    /// Inserts/Saves a record of `BookRecord` given the `BookPayload` in the store
    func save(book: BookPayload) async throws {
        let record = BookRecord(from: book)
        try await bookStore.write([record])
    }
    
    /// Removes a record of `BookRecord` from the store
    func delete(book: BookRecord) async throws {
        try await bookStore.delete(book)
    }
    
    /// Essentially, this reads the saved records of `BookRecord` in the store
    func fetchSavedBooks(_ descriptor: FetchDescriptor<BookRecord>) async throws -> [BookRecord] {
        try await bookStore.read(descriptor)
    }
}
