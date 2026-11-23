import SwiftUI

/// NavigationStack + sheet/cover wired up to an SPRouter.
/// Sheets and covers get their own SPRouterView with a child router.
public struct SPRouterView<Route: SPRoutable, Root: View>: View {
    @State private var router: SPRouter<Route>
    private let root: Root

    public init(for routeType: Route.Type, @ViewBuilder root: () -> Root) {
        _router = State(initialValue: SPRouter<Route>())
        self.root = root()
    }

    /// Use this one if you need the router outside the view (e.g. onOpenURL).
    /// Note: only the first router passed in is used.
    public init(router: SPRouter<Route>, @ViewBuilder root: () -> Root) {
        _router = State(initialValue: router)
        self.root = root()
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            root.navigationDestination(for: Route.self) { $0.destination }
        }
        .sheet(item: presentation(.sheet)) { p in
            SPRouterView<Route, Route.Destination>(router: p.router) { p.route.destination }
        }
        #if !os(macOS)
        .fullScreenCover(item: presentation(.fullScreenCover)) { p in
            SPRouterView<Route, Route.Destination>(router: p.router) { p.route.destination }
        }
        #endif
        .environment(router)
    }

    // swipe-to-dismiss sets this to nil, which clears the router's state too
    private func presentation(
        _ style: SPRouter<Route>.Presentation.Style
    ) -> Binding<SPRouter<Route>.Presentation?> {
        Binding(
            get: { router.presented?.style == style ? router.presented : nil },
            set: { newValue in
                if newValue == nil, router.presented?.style == style {
                    router.presented = nil
                }
            }
        )
    }
}
