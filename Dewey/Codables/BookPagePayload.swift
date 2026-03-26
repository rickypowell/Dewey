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
