import SwiftUI
import SwiftData
import os

fileprivate let logger = Logger(subsystem: "com.ricky-powell.Dewey", category: "BookDetilView")

struct BookDetailView: View {
    @Environment(BookRepository.self) private var bookRepo
    let book: BookPayload
    @State private var bookSaved = false
    @State private var showSaveError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                BookHeroView(bookRepo: bookRepo, book: book)

                if let subjects = book.subject, !subjects.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subjects")
                            .font(.headline)
                            .padding(.horizontal)

                        SubjectScrollView(subjects: subjects)
                    }
                }

                AuthorBooksView(
                    bookRepo: bookRepo.clone(),
                    source: book
                )

                if let subjects = book.subject, !subjects.isEmpty {
                    SubjectBooksView(
                        bookRepo: bookRepo.clone(),
                        source: book
                    )
                }
            }
            .padding(.vertical, 32)
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        do {
                            try await bookRepo.save(book: book)
                            bookSaved = true
                        } catch {
                            showSaveError = true
                        }
                    }
                } label: {
                    Image(systemName: bookSaved ? "checkmark" : "plus")
                }
                .disabled(bookSaved)
            }
        }
        .alert(isPresented: $showSaveError, error: BookStoreError.couldNotSave) {
            // do nothing. Here for debug for now.
        }
    }

}

#if DEBUG
fileprivate class MockBookFetcher: BookFetcher {
    func fetch(_ query: BookQuery) async throws -> BookPagePayload {
        BookPagePayload.default
    }
    func buildFetchURL(_ query: BookQuery) -> URL? { nil }
    func buildBookCoverImageURL(_ book: BookPayload) -> URL? { nil }
}

fileprivate typealias MockBookStore = NoopBookStore

#Preview {
    NavigationStack {
        BookDetailView(book: BookPayload(
            title: "The Great Gatsby",
            authorName: ["F. Scott Fitzgerald"],
            authorKey: ["OL27349A"],
            isbn: ["9780743273565"],
            subject: ["Fiction", "Classic Literature", "American Literature", "Jazz Age"],
            firstPublishYear: 1925,
            coverI: 388076
        ))
    }
    .environment(BookRepository(bookFetcher: MockBookFetcher(), bookStore: MockBookStore()))
}
#endif
