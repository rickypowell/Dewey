//
//  DeweyApp.swift
//  Dewey
//
//  Created by Ricky Powell on 3/25/26.
//

import SwiftUI
import SwiftData

@main
struct DeweyApp: App {
    let networkData = LiveNetworkData()
    
    /// It's important that this is initialized only once so that
    /// corresponding read/write/delete from the same underlying container
    /// are all done from a single context.
    let localModelContainer: ModelContainer = {
        do {
            let schema = Schema(versionedSchema: DeweySchema.self)
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            let cloudContainer = try ModelContainer(
                for: schema,
                migrationPlan: DeweyMigrationPlan.self,
                configurations: [config],
            )
            return cloudContainer
        } catch {
            fatalError("init ModelContainer Failed: \(error.localizedDescription)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .tint(Color.indigo)
                // needed for the initial search by title
                .environment(
                    BookRepository(
                        bookFetcher: OpenLibraryBookFetcher(networkData: networkData),
                        bookStore: LocalBookStore(context: localModelContainer.mainContext),
                    )
                )

        }
        .modelContainer(localModelContainer)
    }
}



