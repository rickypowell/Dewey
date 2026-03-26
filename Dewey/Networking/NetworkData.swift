import Foundation

/// Used in depdenency injection where a call over the network is needed.
///
/// This is useful for mocking in testing and Previews where do not work
/// a connection to the network.
protocol NetworkData {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

/// Calls out the network using the Foundation's URLSession
class LiveNetworkData: NetworkData {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await session.data(from: url)
    }
}
