//
//  DeweyApp.swift
//  Dewey
//
//  Created by Ricky Powell on 3/25/26.
//

import SwiftUI

@main
struct DeweyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color.indigo)
                .environment(
                    BookRepository(
                        bookFetcher: OpenLibraryBookFetcher(networkData: LiveNetworkData())
                    )
                )
        }
    }
}
