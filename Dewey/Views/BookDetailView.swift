import SwiftUI

struct BookDetailView: View {
    @Environment(BookRepository.self) private var bookRepo
    let book: BookPayload

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
                    source: book,
                )

                if let subjects = book.subject, !subjects.isEmpty {
                    SubjectBooksView(
                        source: book,
                    )
                }
            }
            .padding(.vertical, 32)
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
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
    .environment(BookRepository(bookFetcher: MockBookFetcher()))
    .environment(\.moreBookByAuthor, BookRepository(bookFetcher: MockBookFetcher()))
    .environment(\.moreBookBySubject, BookRepository(bookFetcher: MockBookFetcher()))
}
#endif
