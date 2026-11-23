import Foundation
import SwiftUI
import Testing
@testable import SPRouter

enum TestRoute: SPRoutable {
    case a, b, c
    case detail(Int)

    var destination: some View { Text(verbatim: "\(self)") }
}

@MainActor
struct SPRouterTests {
    @Test func push() {
        let router = SPRouter<TestRoute>()
        router.push(.a)
        router.push(contentsOf: [.b, .c])
        #expect(router.path == [.a, .b, .c])
    }

    @Test func pop() {
        let router = SPRouter<TestRoute>(path: [.a, .b, .c])
        router.pop()
        #expect(router.path == [.a, .b])

        router.pop(0)
        router.pop(-1)
        #expect(router.path == [.a, .b])

        router.pop(5)
        #expect(router.path.isEmpty)
    }

    @Test func popTo() {
        let router = SPRouter<TestRoute>(path: [.a, .b, .a, .c])
        #expect(router.pop(to: .a))
        #expect(router.path == [.a, .b, .a])

        #expect(!router.pop(to: .c))
        #expect(router.path == [.a, .b, .a])
    }

    @Test func popToRootAndReplace() {
        let router = SPRouter<TestRoute>(path: [.a, .b])
        router.popToRoot()
        #expect(router.path.isEmpty)

        router.replace(with: [.detail(1), .detail(2)])
        #expect(router.path == [.detail(1), .detail(2)])
    }

    @Test func sheetGetsItsOwnRouter() {
        let root = SPRouter<TestRoute>(path: [.a])
        let child = root.present(sheet: .b)

        #expect(root.sheet == .b)
        #expect(root.presentedRouter === child)
        #expect(child.parent === root)
        #expect(child.root === root)

        child.push(.c)
        #expect(child.path == [.c])
        #expect(root.path == [.a])
    }

    @Test func dismissFromInsideSheet() {
        let root = SPRouter<TestRoute>()
        let child = root.present(sheet: .a)

        child.dismiss()
        #expect(root.sheet == nil)
        #expect(root.presentedRouter == nil)

        root.dismiss() // no parent, nothing happens
        #expect(root.path.isEmpty)
    }

    @Test func presentReplacesPrevious() {
        let root = SPRouter<TestRoute>()
        let first = root.present(sheet: .a)
        let second = root.present(sheet: .a)

        #expect(first !== second)
        #expect(root.presentedRouter === second)
    }

    @Test func sheetOnSheet() {
        let root = SPRouter<TestRoute>()
        let child = root.present(sheet: .a)
        let grandchild = child.present(sheet: .b)

        #expect(grandchild.root === root)

        grandchild.dismiss()
        #expect(child.sheet == nil)
        #expect(root.sheet == .a)

        child.present(sheet: .b)
        child.presentedRouter?.dismissAll()
        #expect(root.sheet == nil)
    }

    @Test func deepLink() {
        let root = SPRouter<TestRoute>(path: [.a])
        let child = root.present(sheet: .b)

        // called from inside the sheet, still resets the root
        let ok = child.open(URL(string: "myapp://detail/42")!) { url in
            guard url.host() == "detail", let id = Int(url.lastPathComponent) else { return nil }
            return [.a, .detail(id)]
        }

        #expect(ok)
        #expect(root.path == [.a, .detail(42)])
        #expect(root.sheet == nil)
    }

    @Test func deepLinkNotHandled() {
        let router = SPRouter<TestRoute>(path: [.a])
        #expect(!router.open(URL(string: "myapp://nope")!) { _ in nil })
        #expect(router.path == [.a])
    }
}
