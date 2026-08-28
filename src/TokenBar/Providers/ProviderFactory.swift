import Foundation

protocol ProviderFactory: Sendable {
    var descriptor: ProviderDescriptor { get }

    func makeConnector(context: ProviderFactoryContext) -> any ProviderConnector
}
