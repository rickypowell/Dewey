import Foundation
import SwiftData

protocol BookStore {
    func write(_ books: [BookRecord]) async throws
    func read(_ descriptor: FetchDescriptor<BookRecord>) async throws -> [BookRecord]
    func delete(_ book: BookRecord) async throws
}

struct LocalBookStore: BookStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func write(_ books: [BookRecord]) async throws {
        for book in books {
            context.insert(book)
        }
        try context.save()
    }

    func read(_ descriptor: FetchDescriptor<BookRecord>) async throws -> [BookRecord] {
        try context.fetch(descriptor)
    }
    
    func delete(_ book: BookRecord) async throws {
        context.delete(book)
        try context.save()
    }
}

/// Especially made for #Preview so you can have a default "no operation"
/// meaining this implementation doesn't do anything useful.
struct NoopBookStore: BookStore {
    func write(_ books: [BookRecord]) async throws {}
    func read(_ descriptor: FetchDescriptor<BookRecord>) async throws -> [BookRecord] {
        []
    }
    func delete(_ book: BookRecord) async throws {}
}

enum BookStoreError: LocalizedError {
    case couldNotSave
    case couldNotDelete
    case couldNotRead
    
    var errorDescription: String? {
        switch self {
        case .couldNotDelete:
            return "Could not delete the Book from the store."
        case .couldNotSave:
            return "Could not save the Book from the store."
        case .couldNotRead:
            return "Could not read the Book from the store."
        }
    }
}
