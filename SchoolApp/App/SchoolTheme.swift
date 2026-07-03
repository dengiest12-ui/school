import SwiftUI
import UIKit

enum SchoolTheme {
    static let accent = Color(red: 0.11, green: 0.46, blue: 0.86)
    static let success = Color(red: 0.07, green: 0.49, blue: 0.28)
    static let warning = Color(red: 0.92, green: 0.58, blue: 0.14)
    static let danger = Color(red: 0.91, green: 0.24, blue: 0.20)
    static let teal = Color(red: 0.11, green: 0.68, blue: 0.61)
    static let graphite = Color(red: 0.15, green: 0.17, blue: 0.22)
    static let muted = Color(red: 0.45, green: 0.47, blue: 0.52)
    static let line = Color.black.opacity(0.07)
    static let surface = Color.white
    static let card = Color.white
    static let tabBar = Color.white
    static let page = Color(red: 0.97, green: 0.98, blue: 0.97)
    static let cardRadius: CGFloat = 22
    static let bottomScrollPadding: CGFloat = 118
}

struct KeyboardDoneToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Готово") {
                UIApplication.shared.hideKeyboard()
            }
        }
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
