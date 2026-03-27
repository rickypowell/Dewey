import Foundation
import SwiftData

/// This is the current, latest schema for the app
typealias DeweySchema = DeweySchemaV1

/// This is the current, latest BookRecord model
/// and should be used as the default way to create a `BookRecord`.
typealias BookRecord = DeweySchema.BookRecordV1

extension BookRecord {
    /// Transforms `BookPayload` to `BookRecord`
    convenience init(from payload: BookPayload) {
        self.init(
            title: payload.title,
            authorName: payload.authorName,
            authorKey: payload.authorKey,
            isbn: payload.isbn,
            subject: payload.subject,
            firstPublishYear: payload.firstPublishYear,
            coverI: payload.coverI,
            timestamp: Date()
        )
    }
}

