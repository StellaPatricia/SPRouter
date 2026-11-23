import SPRouter
import SwiftUI

typealias Router = SPRouter<AppRoute>

struct HomeView: View {
    @Environment(Router.self) private var router

    var body: some View {
        List {
            Section("Push") {
                Button("Item 1") { router.push(.item(1)) }
                Button("Items 1, 2, 3 at once") { router.push(contentsOf: [.item(1), .item(2), .item(3)]) }
            }
            Section("Present") {
                Button("Settings (sheet)") { router.present(sheet: .settings) }
                Button("About (full screen)") { router.present(fullScreenCover: .about) }
            }
        }
        .navigationTitle("Home")
    }
}

struct ItemView: View {
    let number: Int
    @Environment(Router.self) private var router

    var body: some View {
        List {
            LabeledContent("Stack", value: router.path.map { "\($0)" }.joined(separator: " → "))
            LabeledContent("Modal level", value: "\(router.level)")

            Button("Push item \(number + 1)") { router.push(.item(number + 1)) }
            Button("Pop") { router.pop() }
            Button("Pop to item 1") { router.pop(to: .item(1)) }
            Button("Pop to root") { router.popToRoot() }
            Button("Settings (sheet)") { router.present(sheet: .settings) }
        }
        .navigationTitle("Item \(number)")
    }
}

struct SettingsView: View {
    @Environment(Router.self) private var router

    var body: some View {
        List {
            LabeledContent("Modal level", value: "\(router.level)")

            Section("Inside this sheet") {
                Button("Push item 1") { router.push(.item(1)) }
                Button("Another sheet on top") { router.present(sheet: .settings) }
            }
            Section("Close") {
                Button("Dismiss") { router.dismiss() }
                Button("Dismiss all") { router.dismissAll() }
            }
        }
        .navigationTitle("Settings")
    }
}

struct AboutView: View {
    @Environment(Router.self) private var router

    var body: some View {
        List {
            Text("Full-screen cover, with its own stack.")
            Button("Push item 1") { router.push(.item(1)) }
            Button("Close") { router.dismiss() }
        }
        .navigationTitle("About")
    }
}

extension SPRouter {
    // 0 on the root, 1 in a sheet, 2 in a sheet on a sheet...
    var level: Int {
        var count = 0
        var router = parent
        while let r = router {
            count += 1
            router = r.parent
        }
        return count
    }
}
