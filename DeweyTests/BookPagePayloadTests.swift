//
//  BookPagePayloadTests.swift
//  DeweyTests
//
//  Created by Ricky Powell on 3/25/26.
//

import Foundation
import Testing
@testable import Dewey

struct BookPagePayloadTests {

    @Test func decodesFromJSON() throws {
        let json = """
        {
            "num_found": 629,
            "start": 0,
            "docs": [
                {
                    "title": "The Lord of the Rings",
                    "author_name": ["J. R. R. Tolkien"],
                    "author_key": ["OL26320A"],
                    "isbn": ["0395647398"],
                    "subject": ["Fantasy fiction"],
                    "first_publish_year": 1954,
                    "cover_i": 14625765
                }
            ]
        }
        """.data(using: .utf8)!

        let page = try JSONDecoder().decode(BookPagePayload.self, from: json)

        #expect(page.numFound == 629)
        #expect(page.start == 0)
        #expect(page.docs.count == 1)
        #expect(page.docs[0].title == "The Lord of the Rings")
        #expect(page.docs[0].subject == ["Fantasy fiction"])
        #expect(page.docs[0].firstPublishYear == 1954)
        #expect(page.docs[0].coverI == 14625765)
    }

    @Test func encodesToJSON() throws {
        let page = BookPagePayload(
            numFound: 10,
            start: 0,
            docs: [
                BookPayload(
                    title: "Dune",
                    authorName: ["Frank Herbert"],
                    authorKey: ["OL34221A"],
                    isbn: ["0441172717"],
                    subject: ["Science fiction"],
                    firstPublishYear: 1965,
                    coverI: 258027
                )
            ]
        )

        let data = try JSONEncoder().encode(page)
        let decoded = try JSONDecoder().decode(BookPagePayload.self, from: data)

        #expect(decoded.numFound == page.numFound)
        #expect(decoded.start == page.start)
        #expect(decoded.docs.count == 1)
        #expect(decoded.docs[0].title == "Dune")
    }
}
