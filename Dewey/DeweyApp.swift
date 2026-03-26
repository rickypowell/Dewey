//
//  DeweyApp.swift
//  Dewey
//
//  Created by Ricky Powell on 3/25/26.
//

import SwiftUI

@main
struct DeweyApp: App {
    let networkData = LiveNetworkData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color.indigo)
                // needed for the initial search by title
                .environment(
                    BookRepository(
                        bookFetcher: OpenLibraryBookFetcher(networkData: networkData)
                    )
                )
                // needed for the AuthorBooksView that does a separate fetch for books by author
                .environment(\.moreBookByAuthor, BookRepository(
                    bookFetcher: OpenLibraryBookFetcher(networkData: networkData)
                ))
        }
    }
}

extension EnvironmentValues {
    /// separate state for listing books meant to support the feature to fetch by author
    @Entry var moreBookByAuthor = BookRepository(
        bookFetcher: NoopBookFetcher(),
    )
}

