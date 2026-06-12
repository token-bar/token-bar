import Foundation

protocol ProviderFactory: Sendable {
    var descriptor: ProviderDescriptor { get }

    func makeConnector() -> any ProviderConnector
}
