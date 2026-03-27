import SwiftUI

struct BookListItemView: View {
    struct ViewModel {
        let url: URL?
        let title: String
        let authorName: String
        let firstPublishYear: Int?
    }
    let book: ViewModel
    
    var body: some View {
        HStack {
            if let url = book.url {
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
                Text(book.authorName)
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
}
