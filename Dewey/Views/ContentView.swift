import SwiftUI

struct ContentView: View {
    @Environment(BookRepository.self) var bookRepo
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(bookRepo.books, id: \.isbn) { book in
                    NavigationLink(value: book) {
                        HStack {
                            if let url = bookRepo.coverImageURL(for: book) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } else if phase.error != nil {
                                        Color.red.opacity(0.3)
                                    } else {
                                        Color.gray.opacity(0.3)
                                    }
                                }
                                .frame(width: 50, height: 75)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                    .lineLimit(2)
                                Text(book.authorName.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                if let year = book.firstPublishYear {
                                    Text(String(year))
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                    .swipeActions {
                        Button("Add to Reading List", systemImage: "plus.circle", role: .confirm) {
                        }
                    }
                }
            }
            .navigationDestination(for: BookPayload.self) { book in
                BookDetailView(book: book)
            }
            .navigationTitle("Books")
            .searchable(text: $searchText, prompt: "Search books")
            .onSubmit(of: .search) {
                Task {
                    await bookRepo.fetchBooks(tokens: [BookRepository.Token.title(searchText)])
                }
            }
            .overlay {
                if bookRepo.isLoading {
                    ProgressView()
                } else if let errorMessage = bookRepo.errorMessage {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else if bookRepo.books.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
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
    func buildBookCoverImageURL(_ book: BookPayload) -> URL? {
        nil
    }
}

#Preview {
    ContentView()
        .environment(
            BookRepository(
                bookFetcher: MockBookFetcher()
            )
        )
}
#endif
