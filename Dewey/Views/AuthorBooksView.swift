import SwiftUI

struct AuthorBooksView: View {
    @Environment(\.moreBookByAuthor) var bookRepo
    let source: BookPayload
    
    var authorName: String {
        source.authorName.first ?? "Author"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("More from \(authorName) (\(bookRepo.books.count))")
                    .font(.headline)
                    .padding(.horizontal)
                
                if bookRepo.isLoading {
                    ProgressView()
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(bookRepo.books, id: \.self) { book in
                        AuthorBookCard(bookRepo: bookRepo, book: book)
                    }
                }
                .padding(.horizontal)
            }
        }
        .task {
            await bookRepo.fetchBooks(tokens: [.author(authorName)])
        }
    }
}

private struct AuthorBookCard: View {
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
        BookPagePayload(numFound: 3, start: 0, docs: [
            BookPayload(title: "The Great Gatsby", authorName: ["F. Scott Fitzgerald"], authorKey: ["OL27349A"], isbn: ["9780743273565"], subject: nil, firstPublishYear: 1925, coverI: 388076),
            BookPayload(title: "Tender Is the Night", authorName: ["F. Scott Fitzgerald"], authorKey: ["OL27349A"], isbn: ["9780684801544"], subject: nil, firstPublishYear: 1934, coverI: 258027),
            BookPayload(title: "This Side of Paradise", authorName: ["F. Scott Fitzgerald"], authorKey: ["OL27349A"], isbn: ["9780486289991"], subject: nil, firstPublishYear: 1920, coverI: 258024),
        ])
    }
    func buildFetchURL(_ query: BookQuery) -> URL? { nil }
    func buildBookCoverImageURL(_ book: BookPayload) -> URL? { nil }
}

#Preview {
    NavigationStack {
        AuthorBooksView(
            source: BookPayload(title: "The Great Gatsby", authorName: ["F. Scott Fitzgerald"], authorKey: ["OL27349A"], isbn: ["9780743273565"], subject: nil, firstPublishYear: 1925, coverI: 388076),
        )
    }
    .environment(\.moreBookByAuthor, BookRepository(bookFetcher: MockBookFetcher()))
}
#endif
