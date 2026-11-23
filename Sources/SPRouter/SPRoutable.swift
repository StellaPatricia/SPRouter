import SwiftUI

/// Conform your route enum to this and return the view for each case.
public protocol SPRoutable: Hashable, Identifiable {
    associatedtype Destination: View

    @MainActor @ViewBuilder var destination: Destination { get }
}

extension SPRoutable {
    // needed for sheet(item:)
    public var id: Self { self }
}
