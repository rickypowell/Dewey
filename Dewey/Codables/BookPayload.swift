struct BookPayload: Codable {
    let title: String
    let authorName: [String]
    let authorKey: [String]
    let isbn: [String]?
    let subject: [String]?
    let firstPublishYear: Int?
    let coverI: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case authorName = "author_name"
        case authorKey = "author_key"
        case isbn
        case subject
        case firstPublishYear = "first_publish_year"
        case coverI = "cover_i"
    }
}
