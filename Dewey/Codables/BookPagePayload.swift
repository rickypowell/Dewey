/// Structure of the response from the openlibrary.org/search.json API
struct BookPagePayload: Codable {
    let numFound: Int
    let start: Int
    let docs: [BookPayload]

    enum CodingKeys: String, CodingKey {
        case numFound = "num_found"
        case start
        case docs
    }
}

extension BookPagePayload {
    static let `default` = BookPagePayload(numFound: 0, start: 0, docs: [])
    
}
