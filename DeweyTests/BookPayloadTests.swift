//
//  BookPayloadTests.swift
//  DeweyTests
//
//  Created by Ricky Powell on 3/25/26.
//

import Foundation
import Testing
@testable import Dewey

struct BookPayloadTests {

    @Test func decodesFromJSON() throws {
        let json = """
        {
            "key": "/works/abc",
            "title": "The Lord of the Rings",
            "author_name": ["J. R. R. Tolkien"],
            "author_key": ["OL26320A"],
            "isbn": ["0395647398", "0618346252"],
            "subject": ["Fantasy fiction", "Middle Earth (Imaginary place)"],
            "first_publish_year": 1954,
            "cover_i": 14625765
        }
        """.data(using: .utf8)!

        let book = try JSONDecoder().decode(BookPayload.self, from: json)

        #expect(book.key == "/works/abc")
        #expect(book.title == "The Lord of the Rings")
        #expect(book.authorName == ["J. R. R. Tolkien"])
        #expect(book.authorKey == ["OL26320A"])
        #expect(book.isbn == ["0395647398", "0618346252"])
        #expect(book.subject == ["Fantasy fiction", "Middle Earth (Imaginary place)"])
        #expect(book.firstPublishYear == 1954)
        #expect(book.coverI == 14625765)
    }

    @Test func decodesFromJSONWithMissingOptionalFields() throws {
        let json = """
        {
            "key": "/works/abc",
            "title": "The works of Spenser, in six volumes",
            "author_name": ["Edmund Spenser"],
            "author_key": ["OL26320A"],
            "isbn": ["0395647398"]
        }
        """.data(using: .utf8)!

        let book = try JSONDecoder().decode(BookPayload.self, from: json)

        #expect(book.key == "/works/abc")
        #expect(book.title == "The works of Spenser, in six volumes")
        #expect(book.subject == nil)
        #expect(book.firstPublishYear == nil)
        #expect(book.coverI == nil)
    }

    @Test func encodesToJSON() throws {
        let book = BookPayload(
            key: "/works/abc",
            title: "Dune",
            authorName: ["Frank Herbert"],
            authorKey: ["OL34221A"],
            isbn: ["0441172717"],
            subject: ["Science fiction"],
            firstPublishYear: 1965,
            coverI: 258027
        )

        let data = try JSONEncoder().encode(book)
        let decoded = try JSONDecoder().decode(BookPayload.self, from: data)

        #expect(decoded.title == book.title)
        #expect(decoded.authorName == book.authorName)
        #expect(decoded.authorKey == book.authorKey)
        #expect(decoded.isbn == book.isbn)
        #expect(decoded.subject == book.subject)
        #expect(decoded.firstPublishYear == book.firstPublishYear)
        #expect(decoded.coverI == book.coverI)
    }
}
