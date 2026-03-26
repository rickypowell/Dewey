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

        }
    }
}



