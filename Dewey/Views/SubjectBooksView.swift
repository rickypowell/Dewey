import SwiftUI

struct SubjectBooksView: View {
    @Environment(\.moreBookBySubject) var bookRepo
    let source: BookPayload

    var subjectName: String {
        source.subject?.first ?? "Subject"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("More from this subject (\(bookRepo.books.count))")
                    .font(.headline)
                    .padding(.horizontal)

                if bookRepo.isLoading {
                    ProgressView()
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(bookRepo.books, id: \.self) { book in
                        SubjectBookCard(bookRepo: bookRepo, book: book)
                    }
                }
                .padding(.horizontal)
            }
        }
        .task {
            await bookRepo.fetchBooks(tokens: [.subject(subjectName)])
        }
    }
}

private struct SubjectBookCard: View {
    let bookRepo: BookRepository
    let book: BookPayload

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = bookRepo.coverImageURL(for: book) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        CoverPlaceholderView(color: .red.opacity(0.3))
                    } else {
                        CoverPlaceholderView(color: .gray.opacity(0.3))
                            .overlay { ProgressView() }
                    }
                }
                .frame(width: 120, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 4, y: 2)
            } else {
                CoverPlaceholderView(color: .gray.opacity(0.3))
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Text(book.title)
                .font(.caption)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
        }
    }
}

#if DEBUG
fileprivate class MockBookFetcher: BookFetcher {
    func fetch(_ query: BookQuery) async throws -> BookPagePayload {
        BookPagePayload(numFound: 2, start: 0, docs: [
            BookPayload(title: "To Kill a Mockingbird", authorName: ["Harper Lee"], authorKey: ["OL44247A"], isbn: ["9780061120084"], subject: ["Fiction"], firstPublishYear: 1960, coverI: 8228691),
            BookPayload(title: "1984", authorName: ["George Orwell"], authorKey: ["OL118077A"], isbn: ["9780451524935"], subject: ["Fiction"], firstPublishYear: 1949, coverI: 153710),
        ])
    }
    func buildFetchURL(_ query: BookQuery) -> URL? { nil }
    func buildBookCoverImageURL(_ book: BookPayload) -> URL? { nil }
}

#Preview {
    NavigationStack {
        SubjectBooksView(
            source: BookPayload(title: "The Great Gatsby", authorName: ["F. Scott Fitzgerald"], authorKey: ["OL27349A"], isbn: ["9780743273565"], subject: ["Fiction", "Classic Literature"], firstPublishYear: 1925, coverI: 388076),
        )
    }
    .environment(\.moreBookBySubject, BookRepository(bookFetcher: MockBookFetcher()))
}
#endif
