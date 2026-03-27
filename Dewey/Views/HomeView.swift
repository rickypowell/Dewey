import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Tab("Search", systemImage: "magnifyingglass") {
                SearchBookView()
            }
                
            Tab("Reading List", systemImage: "list.bullet") {
                SavedBooksListView()
            }
        }
    }
}
