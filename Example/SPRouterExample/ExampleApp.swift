import SPRouter
import SwiftUI

@main
struct ExampleApp: App {
    @State private var router = SPRouter<AppRoute>()

    var body: some Scene {
        WindowGroup {
            SPRouterView(router: router) { HomeView() }
                // try: xcrun simctl openurl booted sprouterexample://item/7
                .onOpenURL { url in
                    router.open(url) { url in
                        switch url.host() {
                        case "item": Int(url.lastPathComponent).map { [.item($0)] }
                        case "settings": [.settings]
                        default: nil
                        }
                    }
                }
        }
    }
}
