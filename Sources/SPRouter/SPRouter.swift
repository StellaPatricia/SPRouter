import Foundation
import Observation

/// Navigation state for an SPRouterView.
/// Grab it with `@Environment(SPRouter<AppRoute>.self) var router`.
///
/// Every sheet / cover gets its own child router, so pushing from inside a
/// sheet pushes inside that sheet.
@MainActor
@Observable
public final class SPRouter<Route: SPRoutable> {
    public var path: [Route]

    /// The router that presented this one. nil for the root.
    @ObservationIgnored public private(set) weak var parent: SPRouter?

    // what this router is currently presenting (only one at a time)
    var presented: Presentation?

    public init(path: [Route] = []) {
        self.path = path
    }

    init(parent: SPRouter) {
        self.path = []
        self.parent = parent
    }

    public func push(_ route: Route) {
        path.append(route)
    }

    public func push(contentsOf routes: some Sequence<Route>) {
        path.append(contentsOf: routes)
    }

    public func pop(_ count: Int = 1) {
        guard count > 0 else { return }
        path.removeLast(min(count, path.count))
    }

    /// Pops back to the last occurrence of `route`. Returns false if it isn't on the stack.
    @discardableResult
    public func pop(to route: Route) -> Bool {
        guard let index = path.lastIndex(of: route) else { return false }
        path.removeSubrange((index + 1)...)
        return true
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func replace(with routes: [Route]) {
        path = routes
    }

    public var sheet: Route? {
        presented?.style == .sheet ? presented?.route : nil
    }

    @available(macOS, unavailable)
    public var fullScreenCover: Route? {
        presented?.style == .fullScreenCover ? presented?.route : nil
    }

    /// Router of the sheet/cover this router is showing, if any.
    public var presentedRouter: SPRouter? {
        presented?.router
    }

    /// The router at the very bottom (the one with no parent).
    public var root: SPRouter {
        var router = self
        while let parent = router.parent { router = parent }
        return router
    }

    /// Replaces anything already presented by this router.
    @discardableResult
    public func present(sheet route: Route) -> SPRouter {
        present(route, style: .sheet)
    }

    @available(macOS, unavailable)
    @discardableResult
    public func present(fullScreenCover route: Route) -> SPRouter {
        present(route, style: .fullScreenCover)
    }

    /// Closes the sheet/cover this router lives in. Does nothing on the root.
    public func dismiss() {
        parent?.presented = nil
    }

    /// Closes every sheet/cover, all the way back to the root.
    public func dismissAll() {
        root.presented = nil
    }

    /// Closes all modals and sets the root stack to whatever `parse` returns.
    /// If `parse` returns nil nothing happens and this returns false.
    @discardableResult
    public func open(_ url: URL, parse: (URL) -> [Route]?) -> Bool {
        guard let routes = parse(url) else { return false }
        let root = root
        root.presented = nil
        root.path = routes
        return true
    }

    private func present(_ route: Route, style: Presentation.Style) -> SPRouter {
        let child = SPRouter(parent: self)
        presented = Presentation(route: route, style: style, router: child)
        return child
    }
}

extension SPRouter {
    struct Presentation: Identifiable {
        enum Style { case sheet, fullScreenCover }

        // new id each time, so presenting the same route twice still gets a fresh router
        let id = UUID()
        let route: Route
        let style: Style
        let router: SPRouter
    }
}
