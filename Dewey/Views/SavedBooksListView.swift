import SwiftUI
import SwiftData
import os

fileprivate let logger = Logger(subsystem: "com.ricky-powell.Dewey", category: "SavedBooksListView")

struct SavedBooksListView: View {
    @Environment(BookRepository.self) var bookRepo
    @State private var books: [BookRecord] = []
    @State private var showDeleteError = false
    @State private var showReadError = false
    
    let desc = FetchDescriptor<BookRecord>()
    
    var body: some View {
        List {
            ForEach(Array(books.enumerated()), id: \.offset) { (index, book) in
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if let authorName = book.authorName.first {
                        Text(authorName)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    
                    Text(book.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash.circle") {
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
            }
        }
        .onAppear {
            Task {
                do {
                    books = try await bookRepo.fetchSavedBooks(desc)
                } catch {
                    logger.error("failure to fetch saved books: \(error.localizedDescription)")
                    showReadError = true
                }
            }
        }
        .navigationTitle("Saved Books")
        .alert(isPresented: $showReadError, error: BookStoreError.couldNotRead) {
                // nothing to but acknowledge the error
        }
        .alert(isPresented: $showDeleteError, error: BookStoreError.couldNotDelete) {
            // nothing to but acknowledge the error
        }
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
