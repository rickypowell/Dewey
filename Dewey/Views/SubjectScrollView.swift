import SwiftUI

struct SubjectScrollView: View {
    let subjects: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(subjects.prefix(20), id: \.self) { subject in
                    Text(subject)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SubjectScrollView(subjects: [
        "Fiction", "Classic Literature", "American Literature",
        "Jazz Age", "Tragedy", "New York"
    ])
}
