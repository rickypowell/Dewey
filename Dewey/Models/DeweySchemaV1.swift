import Foundation
import SwiftData

enum DeweySchemaV1: VersionedSchema {
    static let versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Self.BookRecordV1.self]
    }

    @Model
    class BookRecordV1 {
        var title: String
        var authorName: [String]
        var authorKey: [String]
        var isbn: [String]?
        var subject: [String]?
        var firstPublishYear: Int?
        var coverI: Int?
        var timestamp: Date

        init(title: String, authorName: [String], authorKey: [String], isbn: [String]?, subject: [String]?, firstPublishYear: Int?, coverI: Int?, timestamp: Date) {
            self.title = title
            self.authorName = authorName
            self.authorKey = authorKey
            self.isbn = isbn
            self.subject = subject
            self.firstPublishYear = firstPublishYear
            self.coverI = coverI
            self.timestamp = timestamp
        }
    }
}
