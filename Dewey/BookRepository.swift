import Foundation

/// This Observable can fetch books using it's given `BookFetcher`.
/// The data is stored in `var book: [BookPayload]` and is initially empty.
@Observable
class BookRepository {
    private(set) var books: [BookPayload] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let bookFetcher: any BookFetcher
    
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

    init(bookFetcher: any BookFetcher) {
        self.bookFetcher = bookFetcher
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
