import Foundation
import SwiftData
import Testing
@testable import Dewey

struct LocalBookStoreTests {
    
    /// convenience for backing a container that is in-memory
    /// and only contains the `BookRecord` model.
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: BookRecord.self, configurations: config)
    }

    /// Tests that writing the book was done to with the context that was passed into the LocalBookStore
    @Test func writeInsertsRecordsIntoContext() async throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = LocalBookStore(context: context)

        let book = makeRecord()
        try await store.write([book])

        let results = try context.fetch(FetchDescriptor<BookRecord>())
        #expect(results.count == 1)
        #expect(results.first?.title == "Emma")
    }

    /// Test that we can write multiple books to the context that was passed into the LocalBookStore
    @Test func writeMultipleRecords() async throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = LocalBookStore(context: context)

        let books = [
            makeRecord(title: "Emma"),
            makeRecord(title: "Pride and Prejudice"),
        ]
        try await store.write(books)

        let results = try context.fetch(FetchDescriptor<BookRecord>())
        #expect(results.count == 2)
    }

    /// Test that we can read from books that were written to the context that was passed into the LocalBookStore
    @Test func readReturnsFetchedRecords() async throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = LocalBookStore(context: context)

        let book = makeRecord(title: "Sense and Sensibility")
        context.insert(book)
        try context.save()

        let results = try await store.read(FetchDescriptor<BookRecord>())
        #expect(results.count == 1)
        #expect(results.first?.title == "Sense and Sensibility")
    }

    /// Tests when the store is empty that read does not throw an error
    @Test func readReturnsEmptyWhenNoRecords() async throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = LocalBookStore(context: context)

        let results = try await store.read(FetchDescriptor<BookRecord>())
        #expect(results.isEmpty)
    }

    /// Test that a write to the store can also delete from that same store
    /// beacuse they both use the same context passed into the LocalBookStore
    @Test func deleteRemovesRecordFromContext() async throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = LocalBookStore(context: context)

        let book = makeRecord()
        try await store.write([book])

        try await store.delete(book)

        let results = try context.fetch(FetchDescriptor<BookRecord>())
        #expect(results.isEmpty)
    }
}

struct BookStoreErrorTests {

    /// Simple test to makes sure we are using the correct
    /// corresponding verbs "save|delete|read"
    @Test func errorDescriptions() {
        #expect(BookStoreError.couldNotSave.errorDescription == "Could not save the Book from the store.")
        #expect(BookStoreError.couldNotDelete.errorDescription == "Could not delete the Book from the store.")
        #expect(BookStoreError.couldNotRead.errorDescription == "Could not read the Book from the store.")
    }
}

/// convenience for creating a `BookRecord`
private func makeRecord(
    title: String = "Emma",
    authorName: [String] = ["Jane Austen"],
    authorKey: [String] = ["OL12345A"]
) -> BookRecord {
    BookRecord(
        title: title,
        authorName: authorName,
        authorKey: authorKey,
        isbn: nil,
        subject: nil,
        firstPublishYear: nil,
        coverI: nil,
        timestamp: Date()
    )
}
