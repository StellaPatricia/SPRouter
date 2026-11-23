# SPRouter

Small router for SwiftUI on top of NavigationStack. iOS 17+ / macOS 14+.

There's a demo app in `Example/` — open `Example/SPRouterExample.xcodeproj` and run it.

## Usage

Make a route enum:

```swift
enum AppRoute: SPRoutable {
    case profile(userID: String)
    case settings

    var destination: some View {
        switch self {
        case .profile(let id): ProfileView(userID: id)
        case .settings: SettingsView()
        }
    }
}
```

Wrap your root view:

```swift
SPRouterView(for: AppRoute.self) {
    HomeView()
}
```

Then use the router from any view inside it:

```swift
@Environment(SPRouter<AppRoute>.self) private var router

router.push(.profile(userID: "42"))
router.pop()
router.pop(to: .settings)
router.popToRoot()
router.present(sheet: .settings)
router.dismiss()
```

`present(fullScreenCover:)` works too, except on macOS.

## Sheets

Each sheet or cover gets its own router and NavigationStack. So inside a sheet, `router` is the sheet's router:

```swift
router.push(.detail)   // pushes inside the sheet
router.present(sheet: .settings)  // sheet on top of the sheet
router.dismiss()       // closes this sheet
router.dismissAll()    // closes every sheet, back to the root
```

`router.parent` and `router.root` give you the routers below it if you need them.

## Deep links

Create the router yourself so you can use it in `onOpenURL`:

```swift
@State private var router = SPRouter<AppRoute>()

var body: some Scene {
    WindowGroup {
        SPRouterView(router: router) { HomeView() }
            .onOpenURL { url in
                router.open(url) { url in
                    switch url.host() {
                    case "settings": [.settings]
                    case "profile": [.profile(userID: url.lastPathComponent)]
                    default: nil
                    }
                }
            }
    }
}
```
