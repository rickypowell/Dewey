import SwiftUI

struct CoverPlaceholderView: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(color)
            .overlay {
                Image(systemName: "book.closed.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview {
    CoverPlaceholderView(color: .gray.opacity(0.3))
        .frame(width: 260, height: 390)
}
