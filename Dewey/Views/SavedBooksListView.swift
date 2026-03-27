import SwiftUI
import SwiftData
import os

fileprivate let logger = Logger(subsystem: "com.ricky-powell.Dewey", category: "SavedBooksListView")

struct SavedBooksListView: View {
    @Environment(BookRepository.self) var bookRepo
    @State private var books: [BookRecord] = []
    @State private var showDeleteError = false
    @State private var showReadError = false
    @State private var showEmptyState = false
    
    let desc = FetchDescriptor<BookRecord>()
    
    var body: some View {
        NavigationStack {
            if showEmptyState {
                ContentUnavailableView("Reading List", systemImage: "book", description: Text("Go to the search screen to find books to add to your list."))
            }
            List {
                ForEach(Array(books.enumerated()), id: \.offset) { (index, book) in
                    NavigationLink(value: book) {
                        BookListItemView(
                            book: .init(
                                url: bookRepo.coverImageURL(for: book),
                                title: book.title,
                                authorName: book.authorName.joined(separator: ", "),
                                firstPublishYear: book.firstPublishYear,
                            ),
                        )
                    }
                    .contextMenu {
                        DeleteBookButton {
                            deleteBook(book)
                        }
                    }
                    .swipeActions {
                        DeleteBookButton {
                            deleteBook(book)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        books = try await bookRepo.fetchSavedBooks(desc)
                        if books.isEmpty {
                            showEmptyState = true
                        }
                    } catch {
                        logger.error("failure to fetch saved books: \(error.localizedDescription)")
                        showReadError = true
                    }
                }
            }
            .navigationDestination(for: BookRecord.self) { book in
                BookDetailView(book: book)
            }
            .alert(isPresented: $showReadError, error: BookStoreError.couldNotRead) {
                    // nothing to but acknowledge the error
            }
            .alert(isPresented: $showDeleteError, error: BookStoreError.couldNotDelete) {
                // nothing to but acknowledge the error
            }
        }
    }
    
    func deleteBook(_ book: BookRecord) {
        Task {
            do {
                try await bookRepo.delete(book: book)
                books.removeAll(where: { $0 == book })
            } catch {
                logger.error("failure to delete book: \(error.localizedDescription)")
                showDeleteError = true
            }
        }
    }
}

fileprivate struct DeleteBookButton: View {
    let action: () -> Void
    var body: some View {
        Button("Delete", systemImage: "trash", role: .destructive) {
            action()
        }
        .tint(.red)
    }
}

#if DEBUG
fileprivate typealias MockBookFetcher = NoopBookFetcher

fileprivate struct MockBookStore: BookStore {
    func write(_ books: [BookRecord]) async throws {}
    func delete(_ book: BookRecord) async throws {}
    func read(_ descriptor: FetchDescriptor<BookRecord>) async throws -> [BookRecord] {
        let cal = Calendar.current
        let now = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: now)!
        let coupleOfDaysAgo = cal.date(byAdding: .day, value: -1, to: now)!
        return [
            BookRecord(
                key: "/works/abc",
                title: "Emma",
                authorName: ["Jane Austen"],
                authorKey: ["abccd"],
                isbn: nil,
                subject: nil,
                firstPublishYear: nil,
                coverI: nil,
                timestamp: coupleOfDaysAgo,
            ),
            BookRecord(
                key: "/works/efg",
                title: "Sense and Sensibility",
                authorName: ["Jane Austen"],
                authorKey: ["abccd"],
                isbn: nil,
                subject: nil,
                firstPublishYear: nil,
                coverI: nil,
                timestamp: yesterday,
            ),
            BookRecord(
                key: "/works/hij",
                title: "The Odessey",
                authorName: ["Homer"],
                authorKey: ["xyz"],
                isbn: nil,
                subject: nil,
                firstPublishYear: nil,
                coverI: nil,
                timestamp: now,
            ),
        ]
    }
}
#Preview {
    SavedBooksListView()
        .environment(BookRepository(bookFetcher: MockBookFetcher(), bookStore: MockBookStore()))
}
#endif
