import SwiftUI

struct SearchBookView: View {
    @Environment(BookRepository.self) var bookRepo
    @State private var searchText = ""
    @State private var previousSearchText = ""

    var body: some View {
        NavigationStack {
            List {
                if bookRepo.books.count > 1 {
                    Section {
                        let resultsText = Text(previousSearchText).bold()
                        Text("Results for \"\(resultsText).\"\nToo many results, please narrow your search or choose one of the following")
                    }
                }
                ForEach(bookRepo.books, id: \.isbn) { book in
                    NavigationLink(value: book) {
                        BookListItemView(
                            book: .init(
                                url: bookRepo.coverImageURL(for: book),
                                title: book.title,
                                authorName: book.authorName.joined(separator: ", "),
                                firstPublishYear: book.firstPublishYear,
                            )
                        )
                    }
                    .swipeActions {
                        Button("Add to Reading List", systemImage: "plus.circle", role: .confirm) {
                        }
                    }
                }
            }
            .navigationDestination(for: BookRecord.self) { book in
                BookDetailView(book: book)
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search books")
            .onSubmit(of: .search) {
                Task {
                    previousSearchText = searchText
                    await bookRepo.fetchBooks(tokens: [BookRepository.Token.title(searchText)])
                }
            }
            .overlay {
                if bookRepo.status == .isLoading {
                    ProgressView()
                } else if let errorMessage = bookRepo.errorMessage {
                    ContentUnavailableView("Error when searching for \"\(previousSearchText)\"", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else if bookRepo.books.isEmpty
                            && !searchText.isEmpty
                            && bookRepo.status == .idle {
                    ContentUnavailableView.search(text: previousSearchText)
                }
            }
        }
    }
}

#if DEBUG
fileprivate class MockBookFetcher: BookFetcher {
    func fetch(_ query: BookQuery) async throws -> BookPagePayload {
        BookPagePayload(numFound: 3, start: 0, docs: [
            BookPayload(title: "The Great Gatsby", authorName: ["F. Scott Fitzgerald"], authorKey: ["OL27349A"], isbn: ["9780743273565"], subject: ["Fiction", "Classic Literature"], firstPublishYear: 1925, coverI: 388076),
            BookPayload(title: "To Kill a Mockingbird", authorName: ["Harper Lee"], authorKey: ["OL502041A"], isbn: ["9780061120084"], subject: ["Fiction", "Southern Gothic"], firstPublishYear: 1960, coverI: 8228691),
            BookPayload(title: "1984", authorName: ["George Orwell"], authorKey: ["OL118077A"], isbn: ["9780451524935"], subject: ["Dystopian Fiction", "Political Fiction"], firstPublishYear: 1949, coverI: 12818862),
        ])
    }
    func buildFetchURL(_ query: BookQuery) -> URL? {
        nil
    }
    func buildBookCoverImageURL(_ coverI: Int?) -> URL? {
        nil
    }
}

fileprivate typealias MockBookStore = NoopBookStore

#Preview {
    SearchBookView()
        .environment(
            BookRepository(
                bookFetcher: MockBookFetcher(),
                bookStore: MockBookStore(),
            )
        )
}
#endif
