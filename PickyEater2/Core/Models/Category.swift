import Foundation

public struct Category: Codable, Equatable {
    public let alias: String
    public let title: String

    public init(alias: String, title: String) {
        self.alias = alias
        self.title = title
    }
}
