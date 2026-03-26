import SwiftUI

struct BookHeroView: View {
    let bookRepo: BookRepository
    let book: BookPayload

    var body: some View {
        if let url = bookRepo.coverImageURL(for: book) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    CoverPlaceholderView(color: .red.opacity(0.3))
                } else {
                    CoverPlaceholderView(color: .gray.opacity(0.3))
                        .overlay { ProgressView() }
                }
            }
            .frame(maxWidth: 260, maxHeight: 390)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 10, y: 5)
        } else {
            CoverPlaceholderView(color: .gray.opacity(0.3))
                .frame(width: 260, height: 390)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        VStack(spacing: 8) {
            Text(book.title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(book.authorName.joined(separator: ", "))
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let year = book.firstPublishYear {
                Text("First published \(String(year))")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }

            if let isbn = book.isbn?.first {
                Text("ISBN \(isbn)")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal)
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

#Preview(traits: .sizeThatFitsLayout) {
    BookHeroView(
        bookRepo: BookRepository(bookFetcher: MockBookFetcher()),
        book: BookPayload(
            title: "The Great Gatsby",
            authorName: ["F. Scott Fitzgerald"],
            authorKey: ["OL27349A"],
            isbn: ["9780743273565"],
            subject: nil,
            firstPublishYear: 1925,
            coverI: nil
        )
    )
}
#endif
