import SPRouter
import SwiftUI

enum AppRoute: SPRoutable {
    case item(Int)
    case settings
    case about

    var destination: some View {
        switch self {
        case .item(let n): ItemView(number: n)
        case .settings: SettingsView()
        case .about: AboutView()
        }
    }
}
